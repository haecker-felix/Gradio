use gstreamer::prelude::*;
use gstreamer_pbutils::prelude::*;
use gtk::prelude::*;
use mpris_player::{Metadata, MprisPlayer, OrgMprisMediaPlayer2Player, PlaybackStatus};
use rustio::{Client, Station};

use std::cell::Cell;
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::mpsc::Sender;
use std::sync::Arc;
use std::thread;

use crate::app::{Action, AppInfo};

pub struct Recorder {
    pub widget: gtk::Box,
    current_station: Cell<Option<Station>>,
    current_song: Rc<RefCell<String>>,

    pipeline: gstreamer::Pipeline,
    uridecodebin: gstreamer::Element,
    audioconvert: gstreamer::Element,
    vorbisenc: gstreamer::Element,
    oggmux: gstreamer::Element,
    filesink: gstreamer::Element,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Recorder {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/recorder.ui");
        let widget: gtk::Box = builder.get_object("recorder").unwrap();
        let current_station = Cell::new(None);
        let current_song = Rc::new(RefCell::new(String::new()));

        let pipeline = gstreamer::Pipeline::new(None);
        let uridecodebin = gstreamer::ElementFactory::make("uridecodebin", "uridecodebin").unwrap();
        let audioconvert = gstreamer::ElementFactory::make("audioconvert", "audioconvert").unwrap();
        let vorbisenc = gstreamer::ElementFactory::make("vorbisenc", "vorbisenc").unwrap();
        let oggmux = gstreamer::ElementFactory::make("oggmux", "oggmux").unwrap();
        let filesink = gstreamer::ElementFactory::make("filesink", "filesink").unwrap();

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

        pipeline.add_many(&[&uridecodebin, &audioconvert, &vorbisenc, &oggmux, &filesink]).unwrap();
        gstreamer::Element::link_many(&[&audioconvert, &vorbisenc, &oggmux, &filesink]).unwrap();
        filesink.set_property("location", &"/dev/null").unwrap();

        let recorder = Self {
            widget,
            current_station,
            current_song,
            pipeline,
            uridecodebin,
            audioconvert,
            vorbisenc,
            oggmux,
            filesink,
            builder,
            sender,
        };

        recorder.setup_signals();
        recorder
    }

    pub fn set_station(&self, station: Station) {
        self.current_station.set(Some(station.clone()));
        let pipeline = self.pipeline.clone();
        let _ = pipeline.set_state(gstreamer::State::Paused);

        let uridecodebin = self.uridecodebin.clone();
        let filesink = self.filesink.clone();
        thread::spawn(move || {
            let mut client = Client::new("http://www.radio-browser.info");
            let station_url = client.get_playable_station_url(station).unwrap();

            let _ = pipeline.set_state(gstreamer::State::Null);
            uridecodebin.set_property("uri", &station_url).unwrap();
            filesink.set_property("location", &"/dev/null").unwrap();
            let _ = pipeline.set_state(gstreamer::State::Playing);
        });
    }

    fn parse_bus_message(message: &gstreamer::Message, pipeline: gstreamer::Pipeline, filesink: gstreamer::Element, current_song: Rc<RefCell<String>>) {
        match message.view() {
            gstreamer::MessageView::Tag(tag) => {
                tag.get_tags().get::<gstreamer::tags::Title>().map(|title| {
                    if *current_song.borrow() != title.get().unwrap() {
                        *current_song.borrow_mut() = title.get().unwrap().to_string();
                        debug!("New song detected: {}", current_song.borrow());
                        let path = &format!("{}/{}.ogg", glib::get_user_special_dir(glib::UserDirectory::Music).unwrap().to_str().unwrap(), title.get().unwrap());
                        debug!("Save song: {}", path);

                        // set state to 'null', so we can change filesink location
                        let _ = pipeline.set_state(gstreamer::State::Null);

                        filesink.set_property("location", path);

                        // start pipeline again
                        let _ = pipeline.set_state(gstreamer::State::Playing);
                    }
                });
            }
            _ => (),
        };
    }

    fn setup_signals(&self) {
        // new pipeline bus messages
        let bus = self.pipeline.get_bus().expect("Unable to get pipeline bus");
        let pipeline = self.pipeline.clone();
        let filesink = self.filesink.clone();
        let current_song = self.current_song.clone();
        gtk::timeout_add(250, move || {
            while bus.have_pending() {
                bus.pop().map(|message| {
                    //debug!("new message {:?}", message);
                    Self::parse_bus_message(&message, pipeline.clone(), filesink.clone(), current_song.clone());
                });
            }
            Continue(true)
        });
    }
}
