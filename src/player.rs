use gstreamer::prelude::*;
use gtk::prelude::*;
use mpris_player::{Metadata, MprisPlayer, OrgMprisMediaPlayer2Player, PlaybackStatus};
use rustio::{Client, Station};

use std::cell::Cell;
use std::rc::Rc;
use std::sync::mpsc::Sender;
use std::sync::Arc;
use std::thread;

use crate::app::{Action, AppInfo};

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
}

impl PlayerWidgets {
    pub fn new(builder: gtk::Builder) -> Self {
        let title_label: gtk::Label = builder.get_object("title_label").unwrap();
        let subtitle_label: gtk::Label = builder.get_object("subtitle_label").unwrap();
        let subtitle_revealer: gtk::Revealer = builder.get_object("subtitle_revealer").unwrap();
        let playback_button_stack: gtk::Stack = builder.get_object("playback_button_stack").unwrap();

        PlayerWidgets {
            title_label,
            subtitle_label,
            subtitle_revealer,
            playback_button_stack,
        }
    }

    pub fn reset(&self) {
        self.title_label.set_text("");
        self.subtitle_label.set_text("");
        self.subtitle_revealer.set_reveal_child(false);
    }
}

pub struct Player {
    pub widget: gtk::ActionBar,
    player_widgets: Rc<PlayerWidgets>,

    playbin: gstreamer::Element,
    mpris: Arc<MprisPlayer>,
    station: Cell<Option<Station>>,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Player {
    pub fn new(sender: Sender<Action>, _info: &AppInfo) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/player.ui");
        let widget: gtk::ActionBar = builder.get_object("player").unwrap();
        let player_widgets = Rc::new(PlayerWidgets::new(builder.clone()));
        let playbin = gstreamer::ElementFactory::make("playbin", "playbin").unwrap();
        let station = Cell::new(None);

        let mpris = MprisPlayer::new("Gradio".to_string(), "Gradio".to_string(), "de.haeckerfelix.Gradio".to_string());
        mpris.set_can_raise(true);
        mpris.set_can_play(false);
        mpris.set_can_seek(false);
        mpris.set_can_set_fullscreen(false);
        mpris.set_can_pause(true);

        let player = Self {
            widget,
            player_widgets,
            playbin,
            mpris,
            station,
            builder,
            sender,
        };

        player.setup_signals();
        player
    }

    pub fn set_station(&self, station: Station) {
        self.widget.set_visible(true);
        self.player_widgets.reset();
        self.player_widgets.title_label.set_text(&station.name);
        self.station.set(Some(station.clone()));
        self.set_playback(PlaybackState::Stopped);

        // set mpris metadata
        let mut metadata = Metadata::new();
        metadata.art_url = Some(station.clone().favicon);
        metadata.artist = Some(vec![station.clone().name]);
        self.mpris.set_metadata(metadata);
        self.mpris.set_can_play(true);

        let p = self.playbin.clone();
        thread::spawn(move || {
            let mut client = Client::new("http://www.radio-browser.info");
            let station_url = client.get_playable_station_url(station).unwrap();
            p.set_property("uri", &station_url).unwrap();
            let _ = p.set_state(gstreamer::State::Playing);
        });
    }

    pub fn set_playback(&self, playback: PlaybackState) {
        match playback {
            PlaybackState::Playing => {
                let _ = self.playbin.set_state(gstreamer::State::Playing);
            }
            PlaybackState::Stopped => {
                let _ = self.playbin.set_state(gstreamer::State::Null);

                // We need to set it manually, because we don't receive a gst message when the playback stops
                self.player_widgets.playback_button_stack.set_visible_child_name("start_playback");
                self.mpris.set_playback_status(PlaybackStatus::Stopped);
            }
            _ => (),
        };
    }

    fn parse_bus_message(message: &gstreamer::Message, player_widgets: Rc<PlayerWidgets>, mpris: Arc<MprisPlayer>) {
        match message.view() {
            gstreamer::MessageView::Tag(tag) => {
                tag.get_tags().get::<gstreamer::tags::Title>().map(|title| {
                    debug!("playback title changed: {:?}", title);

                    // TODO: this would override the artist/art_url field. Needs to be fixed at mpris_player
                    // let mut metadata = Metadata::new();
                    // metadata.title = Some(title.get().unwrap().to_string());
                    // mpris.set_metadata(metadata);

                    if title.get().unwrap() != "" {
                        player_widgets.subtitle_label.set_text(title.get().unwrap());
                        player_widgets.subtitle_revealer.set_reveal_child(true);
                    } else {
                        player_widgets.subtitle_label.set_text("");
                        player_widgets.subtitle_revealer.set_reveal_child(false);
                    }
                });
            }
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
            }
            _ => (),
        };
    }

    fn setup_signals(&self) {
        // eventbox
        let eventbox: gtk::EventBox = self.builder.get_object("eventbox").unwrap();
        let sender = self.sender.clone();
        eventbox.connect_button_press_event(move |_, _| {
            sender.send(Action::ViewShowCurrentPlayback).unwrap();
            gtk::Inhibit(false)
        });

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

        // new playbin bus messages
        let bus = self.playbin.get_bus().expect("Unable to get playbin bus");
        let player_widgets = self.player_widgets.clone();
        let mpris = self.mpris.clone();
        gtk::timeout_add(250, move || {
            while bus.have_pending() {
                bus.pop().map(|message| Self::parse_bus_message(&message, player_widgets.clone(), mpris.clone()));
            }
            Continue(true)
        });
    }
}
