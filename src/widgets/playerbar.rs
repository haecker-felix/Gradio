extern crate gtk;
use gtk::prelude::*;

use app::AppState;
use std::cell::RefCell;
use std::rc::Rc;

use rustio::station::Station;
use audioplayer::{Update, State};
use favicon_downloader::FaviconDownloader;

pub struct Playerbar {
    app_state: Rc<RefCell<AppState>>,

    pub container: gtk::ActionBar,
    builder: gtk::Builder,

    fdl: Rc<FaviconDownloader>,
}

impl Playerbar {
    pub fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("playerbar.ui"));
        let container: gtk::ActionBar = builder.get_object("playerbar").unwrap();

        let fdl = Rc::new(FaviconDownloader::new());

        let playerbar = Self {
            app_state,
            container,
            builder,
            fdl,
        };

        playerbar.connect_signals();
        playerbar
    }

    fn connect_signals(&self){
        let start_playback_button: gtk::Button = self.builder.get_object("start_playback_button").unwrap();
        let app_state = self.app_state.clone();
        start_playback_button.connect_clicked(move|_|{
            app_state.borrow_mut().player.set_playback(true);
        });

        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let app_state = self.app_state.clone();
        stop_playback_button.connect_clicked(move|_|{
            app_state.borrow_mut().player.set_playback(false);
        });

        let app_state = self.app_state.clone();
        let container = self.container.clone();
        let fdl = self.fdl.clone();
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        let subtitle_label: gtk::Label = self.builder.get_object("subtitle_label").unwrap();
        let subtitle_revealer: gtk::Revealer = self.builder.get_object("subtitle_revealer").unwrap();
        let favicon_image: gtk::Image = self.builder.get_object("favicon_image").unwrap();
        let playback_stack: gtk::Stack = self.builder.get_object("playback_stack").unwrap();
        app_state.borrow_mut().player.register_update_callback(move |update|{
            match update{
                Update::Station(station) => {
                    container.set_visible(true);
                    title_label.set_text(&station.name);
                    favicon_image.set_from_icon_name("emblem-music-symbolic", 40);
                    fdl.set_favicon_async(&favicon_image, &station, 40);
                },
                Update::Title(title) => {
                    if title == "" { subtitle_revealer.set_reveal_child(false);
                    }else{subtitle_revealer.set_reveal_child(true);}
                    subtitle_label.set_text(&title);

                },
                Update::Playback(playback) => {
                    match playback{
                        State::Playing => playback_stack.set_visible_child_name("stop_playback"),
                        State::Stopped => playback_stack.set_visible_child_name("start_playback"),
                        State::Loading => playback_stack.set_visible_child_name("loading"),
                    };
                }
            }
        });
    }
}
