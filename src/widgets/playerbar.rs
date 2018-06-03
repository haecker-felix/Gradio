extern crate gtk;
use gtk::prelude::*;

use app::AppState;
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
            app_state.borrow_mut().player.set_playback(true);
        });

        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let app_state = self.app_state.clone();
        stop_playback_button.connect_clicked(move|_|{
            app_state.borrow_mut().player.set_playback(false);
        });

        let playback_stack: gtk::Stack = self.builder.get_object("playback_stack").unwrap();
        let container: gtk::ActionBar = self.builder.get_object("playerbar").unwrap();
        self.app_state.borrow_mut().player.connect_playback_changed(move|player|{
            if player.playback(){
                container.set_visible(true);
                playback_stack.set_visible_child_name("stop_playback");
            }else{
                playback_stack.set_visible_child_name("start_playback");
            }

        });

        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        let favicon_image: gtk::Image = self.builder.get_object("favicon_image").unwrap();
        let app_state = self.app_state.clone();
        self.app_state.borrow_mut().player.connect_station_changed(move|player|{
            title_label.set_text(&player.station().unwrap().name);
            //app_state.borrow_mut().fdl.set_favicon_async(&favicon_image, &player.station().unwrap(), 32);
        });
    }
}
