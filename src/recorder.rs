use gtk::prelude::*;
use libhandy::{ActionRow, ActionRowExt};
use rustio::{Client, Station};
use gstreamer::ElementExt;
use gstreamer::prelude::*;

use std::cell::{Cell, RefCell};
use std::rc::Rc;
use std::sync::{Arc, Mutex};
use std::sync::mpsc::Sender;
use std::thread;

use crate::app::Action;
use crate::recorder_backend::RecorderBackend;

pub struct Recorder {
    pub widget: gtk::Box,
    last_played_listbox: gtk::ListBox,
    current_station: Cell<Option<Station>>,
    current_song: Rc<RefCell<String>>,
    backend: Arc<Mutex<RecorderBackend>>,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Recorder {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/recorder.ui");
        let widget: gtk::Box = builder.get_object("recorder").unwrap();
        let last_played_listbox: gtk::ListBox = builder.get_object("last_played_listbox").unwrap();
        let current_station = Cell::new(None);
        let current_song = Rc::new(RefCell::new("".to_string()));

        // create gstreamer backend
        let backend = Arc::new(Mutex::new(RecorderBackend::new()));

        let recorder = Self {
            widget,
            last_played_listbox,
            current_station,
            current_song,
            backend,
            builder,
            sender,
        };

        recorder.setup_signals();
        recorder
    }

    pub fn set_station(&self, station: Station) {
        self.current_station.set(Some(station.clone()));

        let backend = self.backend.clone();
        thread::spawn(move || {
            let mut client = Client::new("http://www.radio-browser.info");
            let station_url = client.get_playable_station_url(station).unwrap();
            debug!("new source uri to record: {}", station_url);
            backend.lock().unwrap().new_source_uri(&station_url)
        });
    }

    fn parse_bus_message(message: &gstreamer::Message, backend: Arc<Mutex<RecorderBackend>>, current_song: Rc<RefCell<String>>, last_played_listbox: gtk::ListBox) {
        match message.view() {
            gstreamer::MessageView::Tag(tag) => {
                tag.get_tags().get::<gstreamer::tags::Title>().map(|title| {
                    // Check if song have changed
                    if *current_song.borrow() != title.get().unwrap() {
                        // Create row for old song
                        if *current_song.borrow() != "" {
                            let row = libhandy::ActionRow::new();
                            row.set_title(&*current_song.borrow());
                            row.set_visible(true);
                            last_played_listbox.add(&row);
                        }

                        *current_song.borrow_mut() = title.get().unwrap().to_string();
                        debug!("New song detected: {}", current_song.borrow());

                        debug!("Block the dataflow ...");
                        let gstp = backend.clone();
                        let id = backend.lock().unwrap().queue_srcpad.add_probe (gstreamer::PadProbeType::BLOCK_DOWNSTREAM, move|_, _|{
                            // Dataflow is blocked
                            debug!("Pad is blocked now.");

                            debug!("Push EOS into muxsinkbin sinkpad...");
                            let sinkpad = gstp.lock().unwrap().muxsinkbin.clone().unwrap().get_static_pad("sink").unwrap();
                            sinkpad.send_event(gstreamer::Event::new_eos().build());

                            gstreamer::PadProbeReturn::Ok
                        }).unwrap();

                        // We need the padprobe id later to remove the block probe
                        backend.lock().unwrap().queue_blockprobe_id = Some(id);
                    }
                });
            },
            gstreamer::MessageView::Element(element) => {
                let structure = element.get_structure().unwrap();
                if structure.get_name() == "GstBinForwarded" {
                    let message: gstreamer::message::Message = structure.get("message").unwrap();
                    if let gstreamer::MessageView::Eos(_) = &message.view(){
                        debug!("muxsinkbin got EOS...");
                        let path = &format!("{}/{}.ogg", glib::get_user_special_dir(glib::UserDirectory::Music).unwrap().to_str().unwrap(), &*current_song.borrow());

                        // Old song is closed correctly, so we can start with the new song now
                        backend.lock().unwrap().new_filesink_location(&path);
                    }
                }
            },
            _ => (),
        };
    }

    fn setup_signals(&self) {
        let bus = self.backend.lock().unwrap().pipeline.get_bus().expect("Unable to get pipeline bus");
        let backend = self.backend.clone();
        let current_song = self.current_song.clone();
        let last_played_listbox = self.last_played_listbox.clone();
        gtk::timeout_add(250, move || {
            while bus.have_pending() {
                bus.pop().map(|message| {
                    //debug!("new message {:?}", message);
                    Self::parse_bus_message(&message, backend.clone(), current_song.clone(), last_played_listbox.clone());
                });
            }
            Continue(true)
        });
    }
}
