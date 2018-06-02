extern crate gtk;
use gtk::prelude::*;

use app::AppState;
use rustio::station::Station;
use std::cell::RefCell;
use std::rc::Rc;

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
            app_state.borrow().player.set_playback(true);
        });

        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let app_state = self.app_state.clone();
        stop_playback_button.connect_clicked(move|_|{
            app_state.borrow().player.set_playback(false);
        });
    }
}
