use gstreamer::prelude::*;
use gtk::prelude::*;
use mpris_player::{Metadata, MprisPlayer, OrgMprisMediaPlayer2Player, PlaybackStatus};
use rustio::{Client, Station};
use libhandy::ActionRowExt;

use std::cell::{Cell, RefCell};
use std::rc::Rc;
use std::sync::mpsc::Sender;
use std::sync::{Arc, Mutex};
use std::thread;

use crate::app::Action;
use crate::gstreamer_backend::GstreamerBackend;

pub enum PlaybackState {
    Playing,
    Stopped,
    Loading,
}

struct PlayerWidgets {
    pub title_label: gtk::Label,
    pub subtitle_label: gtk::Label,
    pub subtitle_revealer: gtk::Revealer,
    pub playback_button_stack: gtk::Stack,
    pub last_played_listbox: gtk::ListBox,
}

impl PlayerWidgets {
    pub fn new(builder: gtk::Builder) -> Self {
        let title_label: gtk::Label = builder.get_object("title_label").unwrap();
        let subtitle_label: gtk::Label = builder.get_object("subtitle_label").unwrap();
        let subtitle_revealer: gtk::Revealer = builder.get_object("subtitle_revealer").unwrap();
        let playback_button_stack: gtk::Stack = builder.get_object("playback_button_stack").unwrap();
        let last_played_listbox: gtk::ListBox = builder.get_object("last_played_listbox").unwrap();

        PlayerWidgets {
            title_label,
            subtitle_label,
            subtitle_revealer,
            playback_button_stack,
            last_played_listbox,
        }
    }

    pub fn reset(&self) {
        self.title_label.set_text("");
        self.subtitle_label.set_text("");
        self.subtitle_revealer.set_reveal_child(false);
    }

    pub fn set_title(&self, title: &str){
        if title != "" {
            self.subtitle_label.set_text(title);
            self.subtitle_revealer.set_reveal_child(true);
        } else {
            self.subtitle_label.set_text("");
            self.subtitle_revealer.set_reveal_child(false);
        }
    }
}


pub struct Player {
    pub widget: gtk::Box,
    player_widgets: Rc<PlayerWidgets>,

    backend: Arc<Mutex<GstreamerBackend>>,
    mpris: Arc<MprisPlayer>,
    current_station: Cell<Option<Station>>,
    current_song: Rc<RefCell<String>>,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Player {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/player.ui");
        let widget: gtk::Box = builder.get_object("player").unwrap();
        let player_widgets = Rc::new(PlayerWidgets::new(builder.clone()));
        let backend = Arc::new(Mutex::new(GstreamerBackend::new()));
        let current_station = Cell::new(None);
        let current_song = Rc::new(RefCell::new("".to_string()));

        let mpris = MprisPlayer::new("Gradio".to_string(), "Gradio".to_string(), "de.haeckerfelix.Gradio".to_string());
        mpris.set_can_raise(true);
        mpris.set_can_play(false);
        mpris.set_can_seek(false);
        mpris.set_can_set_fullscreen(false);
        mpris.set_can_pause(true);

        let player = Self {
            widget,
            player_widgets,
            backend,
            mpris,
            current_station,
            current_song,
            builder,
            sender,
        };

        player.setup_signals();
        player
    }

    pub fn set_station(&self, station: Station) {
        self.player_widgets.reset();
        self.player_widgets.title_label.set_text(&station.name);
        self.current_station.set(Some(station.clone()));
        self.set_playback(PlaybackState::Stopped);

        // set mpris metadata
        let mut metadata = Metadata::new();
        metadata.art_url = Some(station.clone().favicon);
        metadata.artist = Some(vec![station.clone().name]);
        self.mpris.set_metadata(metadata);
        self.mpris.set_can_play(true);

        let backend = self.backend.clone();
        thread::spawn(move || {
            let mut client = Client::new("http://www.radio-browser.info");
            let station_url = client.get_playable_station_url(station).unwrap();
            debug!("new source uri to record: {}", station_url);
            backend.lock().unwrap().new_source_uri(&station_url);
        });
    }

    pub fn set_playback(&self, playback: PlaybackState) {
        match playback {
            PlaybackState::Playing => {
                let _ = self.backend.lock().unwrap().set_state(gstreamer::State::Playing);
            }
            PlaybackState::Stopped => {
                let _ = self.backend.lock().unwrap().set_state(gstreamer::State::Null);

                // We need to set it manually, because we don't receive a gst message when the playback stops
                self.player_widgets.playback_button_stack.set_visible_child_name("start_playback");
                self.mpris.set_playback_status(PlaybackStatus::Stopped);
            }
            _ => (),
        };
    }

    fn parse_bus_message(message: &gstreamer::Message, player_widgets: Rc<PlayerWidgets>, mpris: Arc<MprisPlayer>, backend: Arc<Mutex<GstreamerBackend>>, current_song: Rc<RefCell<String>>) {
        match message.view() {
            gstreamer::MessageView::Tag(tag) => {
                tag.get_tags().get::<gstreamer::tags::Title>().map(|title| {
                    // Check if song have changed
                    if *current_song.borrow() != title.get().unwrap() {
                        // save/close old song, and add to song history
                        if *current_song.borrow() != "" {
                            let row = libhandy::ActionRow::new();
                            row.set_title(&*current_song.borrow());
                            row.set_visible(true);
                            player_widgets.last_played_listbox.add(&row);
                        }

                        *current_song.borrow_mut() = title.get().unwrap().to_string();
                        debug!("New song: {:?}", title);
                        player_widgets.set_title(title.get().unwrap());

                        // TODO: this would override the artist/art_url field. Needs to be fixed at mpris_player
                        // let mut metadata = Metadata::new();
                        // metadata.title = Some(title.get().unwrap().to_string());
                        // mpris.set_metadata(metadata);

                        debug!("Block the dataflow ...");
                        backend.lock().unwrap().block_dataflow();
                    }

                });
            },
            gstreamer::MessageView::StateChanged(sc) => {
                debug!("playback state changed: {:?}", sc.get_current());
                let playback_state = match sc.get_current() {
                    gstreamer::State::Playing => PlaybackState::Playing,
                    gstreamer::State::Paused => PlaybackState::Loading,
                    gstreamer::State::Ready => PlaybackState::Loading,
                    _ => PlaybackState::Stopped,
                };

                match playback_state {
                    PlaybackState::Playing => {
                        player_widgets.playback_button_stack.set_visible_child_name("stop_playback");
                        mpris.set_playback_status(PlaybackStatus::Playing);
                    }
                    PlaybackState::Stopped => {
                        player_widgets.playback_button_stack.set_visible_child_name("start_playback");
                        mpris.set_playback_status(PlaybackStatus::Stopped);
                    }
                    PlaybackState::Loading => {
                        player_widgets.playback_button_stack.set_visible_child_name("loading");
                        mpris.set_playback_status(PlaybackStatus::Stopped);
                    }
                };
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
        // start_playback_button
        let start_playback_button: gtk::Button = self.builder.get_object("start_playback_button").unwrap();
        let sender = self.sender.clone();
        start_playback_button.connect_clicked(move |_| {
            sender.send(Action::PlaybackStart).unwrap();
        });

        // stop_playback_button
        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let sender = self.sender.clone();
        stop_playback_button.connect_clicked(move |_| {
            sender.send(Action::PlaybackStop).unwrap();
        });

        // mpris raise
        let sender = self.sender.clone();
        self.mpris.connect_raise(move || {
            sender.send(Action::ViewRaise).unwrap();
        });

        // mpris play / pause
        let sender = self.sender.clone();
        let mpris = self.mpris.clone();
        self.mpris.connect_play_pause(move || {
            match mpris.get_playback_status().unwrap().as_ref() {
                "Paused" => sender.send(Action::PlaybackStart).unwrap(),
                "Stopped" => sender.send(Action::PlaybackStart).unwrap(),
                _ => sender.send(Action::PlaybackStop).unwrap(),
            };
        });

        // new backend (pipeline) bus messages
        let bus = self.backend.lock().unwrap().pipeline.get_bus().expect("Unable to get pipeline bus");
        let player_widgets = self.player_widgets.clone();
        let backend = self.backend.clone();
        let current_song = self.current_song.clone();
        let mpris = self.mpris.clone();
        gtk::timeout_add(250, move || {
            while bus.have_pending() {
                bus.pop().map(|message|{
                    debug!("new message {:?}", message);
                    Self::parse_bus_message(&message, player_widgets.clone(), mpris.clone(), backend.clone(), current_song.clone());
                });
            }
            Continue(true)
        });
    }
}
