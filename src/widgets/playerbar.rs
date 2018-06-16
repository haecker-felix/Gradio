extern crate gtk;
use gtk::prelude::*;

use app::AppState;
use std::cell::RefCell;
use std::rc::Rc;

use rustio::station::Station;
use audioplayer::Update;

pub struct Playerbar {
    app_state: Rc<RefCell<AppState>>,

    pub container: gtk::ActionBar,
    builder: gtk::Builder,
}

impl Playerbar {
    pub fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("playerbar.ui"));

        let container: gtk::ActionBar = builder.get_object("playerbar").unwrap();

        let playerbar = Self { app_state, container, builder };
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
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        let subtitle_label: gtk::Label = self.builder.get_object("subtitle_label").unwrap();
        let favicon_image: gtk::Image = self.builder.get_object("favicon_image").unwrap();
        let playback_stack: gtk::Stack = self.builder.get_object("playback_stack").unwrap();
        app_state.borrow_mut().player.register_update_callback(move |update|{
            match update{
                Update::Station(station) => {
                    container.set_visible(true);
                    title_label.set_text(&station.name);
                },
                Update::Playback(playback) => {
                    if playback{
                        playback_stack.set_visible_child_name("stop_playback");
                    }else{
                        playback_stack.set_visible_child_name("start_playback");
                    }
                }
            }
        });
    }
}
