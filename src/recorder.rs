use gstreamer::prelude::*;
use gstreamer_pbutils::prelude::*;
use gtk::prelude::*;
use mpris_player::{Metadata, MprisPlayer, OrgMprisMediaPlayer2Player, PlaybackStatus};
use rustio::{Client, Station};
use gstreamer::ElementExt;
use gstreamer::BinExt;

use std::cell::Cell;
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::Arc;
use std::sync::Mutex;
use std::sync::mpsc::Sender;
use std::thread;

use crate::app::{Action, AppInfo};

/////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                         //
//  # Gstreamer Pipeline #                                                                 //
//    --------------      --------------      -----------      -------      ------------   //
//   | uridecodebin | -> | audioconvert | -> | vorbisenc | -> | queue | -> | muxsinkbin |  //
//    --------------      --------------      -----------      -------      ------------   //
//                                                                                         //
//  # muxsinkbin:  (gstreamer::Bin) #                                                      //
//    --------------------------------------------                                         //
//   |                  --------      ----------  |                                        //
//   | ( ghostpad ) -> | oggmux | -> | filesink | |                                        //
//   |                  --------      ----------  |                                        //
//    --------------------------------------------                                         //
//                                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////

pub struct GstBackend{
    pub pipeline: gstreamer::Pipeline,

    pub uridecodebin: gstreamer::Element,
    pub audioconvert: gstreamer::Element,
    pub vorbisenc: gstreamer::Element,
    pub queue: gstreamer::Element,
    pub muxsinkbin: Option<gstreamer::Bin>,

    pub queue_srcpad: gstreamer::Pad,
    pub queue_blockprobe_id: Option<gstreamer::PadProbeId>,
}

impl GstBackend{
    pub fn new() -> Self{
        // create gstreamer pipeline
        let pipeline = gstreamer::Pipeline::new("recorder_pipeline");

        // create pipeline elements
        let uridecodebin = gstreamer::ElementFactory::make("uridecodebin", "uridecodebin").unwrap();
        let audioconvert = gstreamer::ElementFactory::make("audioconvert", "audioconvert").unwrap();
        let vorbisenc = gstreamer::ElementFactory::make("vorbisenc", "vorbisenc").unwrap();
        let queue = gstreamer::ElementFactory::make("queue", "queue").unwrap();

        // link pipeline elements
        pipeline.add_many(&[&uridecodebin, &audioconvert, &vorbisenc, &queue]).unwrap();
        gstreamer::Element::link_many(&[&audioconvert, &vorbisenc, &queue]).unwrap();

        // dynamically link uridecodebin element with audioconvert element
        let convert = audioconvert.clone();
        uridecodebin.connect_pad_added(move |uridecodebin, src_pad|{
            let sink_pad = convert.get_static_pad("sink").expect("Failed to get static sink pad from convert");
            if sink_pad.is_linked() {
                return; // We are already linked. Ignoring.
            }

            let new_pad_caps = src_pad.get_current_caps().expect("Failed to get caps of new pad.");
            let new_pad_struct = new_pad_caps.get_structure(0).expect("Failed to get first structure of caps.");
            let new_pad_type = new_pad_struct.get_name();

            if new_pad_type.starts_with("audio/x-raw") { // check if new_pad is audio
                let _ = src_pad.link(&sink_pad);
                return;
            }
        });

        let queue_srcpad = queue.get_static_pad("src").unwrap();

        let mut pipeline = Self{
            pipeline,
            uridecodebin,
            audioconvert,
            vorbisenc,
            queue,
            muxsinkbin: None,
            queue_srcpad,
            queue_blockprobe_id: None,
        };

        pipeline.create_muxsinkbin("/dev/null");
        pipeline
    }

    pub fn new_source_uri(&mut self, source: &str){
        debug!("Stop pipeline...");
        let _ = self.pipeline.set_state(gstreamer::State::Null);

        debug!("Set new source uri...");
        self.uridecodebin.set_property("uri", &source).unwrap();

        debug!("Start pipeline...");
        let _ = self.pipeline.set_state(gstreamer::State::Playing);
    }

    pub fn new_filesink_location(&mut self, location: &str){
        debug!("Update filesink location to \"{}\"...", location);

        debug!("Destroy old muxsinkbin");
        let muxsinkbin = self.muxsinkbin.take().unwrap();
        muxsinkbin.set_state(gstreamer::State::Null);
        self.pipeline.remove(&muxsinkbin);

        debug!("Create new muxsinkbin");
        self.create_muxsinkbin(location);

        debug!("Remove block probe...");
        self.queue_srcpad.remove_probe(self.queue_blockprobe_id.take().unwrap());
    }

    fn create_muxsinkbin(&mut self, location: &str){
        // Create oggmux
        let oggmux = gstreamer::ElementFactory::make("oggmux", "oggmux").unwrap();

        // Create filesink
        let filesink = gstreamer::ElementFactory::make("filesink", "filesink").unwrap();
        filesink.set_property("location", &location).unwrap();

        // Create bin
        let bin = gstreamer::Bin::new("bin");
        bin.set_property("message-forward", &true).unwrap();

        // Add elements to bin and link them
        bin.add(&oggmux).unwrap();
        bin.add(&filesink).unwrap();
        gstreamer::Element::link_many(&[&oggmux, &filesink]).unwrap();

        // Add bin to pipeline
        self.pipeline.add(&bin).unwrap();

        // Link queue src pad with oggmux sinkpad using a ghostpad
        let sinkpad_template = oggmux.get_pad_template("audio_%u").unwrap();
        let oggmux_sinkpad = oggmux.request_pad(&sinkpad_template, None, None).unwrap();

        let ghostpad = gstreamer::GhostPad::new("sink", &oggmux_sinkpad).unwrap();
        bin.add_pad(&ghostpad).unwrap();
        bin.sync_state_with_parent();

        if self.queue_srcpad.link(&ghostpad) != gstreamer::PadLinkReturn::Ok {
            warn!("Queue src pad cannot linked to oggmux sinkpad");
        }

        self.muxsinkbin = Some(bin);
    }
}


pub struct Recorder {
    pub widget: gtk::Box,
    current_station: Cell<Option<Station>>,
    current_song: Rc<RefCell<String>>,
    gst_backend: Arc<Mutex<GstBackend>>,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Recorder {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/recorder.ui");
        let widget: gtk::Box = builder.get_object("recorder").unwrap();
        let current_station = Cell::new(None);
        let current_song = Rc::new(RefCell::new("".to_string()));

        // create gstreamer pipeline
        let gst_backend = Arc::new(Mutex::new(GstBackend::new()));

        let recorder = Self {
            widget,
            current_station,
            current_song,
            gst_backend,
            builder,
            sender,
        };

        recorder.setup_signals();
        recorder
    }

    pub fn set_station(&self, station: Station) {
        self.current_station.set(Some(station.clone()));
        let _ = self.gst_backend.lock().unwrap().pipeline.set_state(gstreamer::State::Paused);

        let gst_backend = self.gst_backend.clone();
        thread::spawn(move || {
            let mut client = Client::new("http://www.radio-browser.info");
            let station_url = client.get_playable_station_url(station).unwrap();
            debug!("new source uri to record: {}", station_url);
            gst_backend.lock().unwrap().new_source_uri(&station_url)
        });
    }

    fn parse_bus_message(message: &gstreamer::Message, gstpipe: Arc<Mutex<GstBackend>>, current_song: Rc<RefCell<String>>) {
        match message.view() {
            gstreamer::MessageView::Tag(tag) => {
                tag.get_tags().get::<gstreamer::tags::Title>().map(|title| {
                    // Check if song have changed
                    if *current_song.borrow() != title.get().unwrap() {
                        *current_song.borrow_mut() = title.get().unwrap().to_string();
                        debug!("New song detected: {}", current_song.borrow());

                        debug!("Block the dataflow ...");
                        let gstp = gstpipe.clone();
                        let id = gstpipe.lock().unwrap().queue_srcpad.add_probe (gstreamer::PadProbeType::BLOCK_DOWNSTREAM, move|pad, info|{
                            debug!("Pad is blocked now.");

                            debug!("Push EOS into muxsinkbin sinkpad...");
                            let sinkpad = gstp.lock().unwrap().muxsinkbin.clone().unwrap().get_static_pad("sink").unwrap();
                            sinkpad.send_event(gstreamer::Event::new_eos().build());

                            gstreamer::PadProbeReturn::Ok
                        }).unwrap();

                        // We need the padprobe id later to remove the block probe
                        gstpipe.lock().unwrap().queue_blockprobe_id = Some(id);
                    }
                });
            },
            gstreamer::MessageView::Element(element) => {
                let structure = element.get_structure().unwrap();
                if structure.get_name() == "GstBinForwarded" {
                    let message: gstreamer::message::Message = structure.get("message").unwrap();
                    if let gstreamer::MessageView::Eos(eos) = &message.view(){
                        debug!("muxsinkbin got EOS...");
                        let path = &format!("{}/{}.ogg", glib::get_user_special_dir(glib::UserDirectory::Music).unwrap().to_str().unwrap(), &*current_song.borrow());
                        gstpipe.lock().unwrap().new_filesink_location(&path);
                    }
                }
            },
            _ => (),
        };
    }

    fn setup_signals(&self) {
        let bus = self.gst_backend.lock().unwrap().pipeline.get_bus().expect("Unable to get pipeline bus");
        let gst_backend = self.gst_backend.clone();
        let current_song = self.current_song.clone();
        gtk::timeout_add(250, move || {
            while bus.have_pending() {
                bus.pop().map(|message| {
                    //debug!("new message {:?}", message);
                    Self::parse_bus_message(&message, gst_backend.clone(), current_song.clone());
                });
            }
            Continue(true)
        });
    }
}
