use gtk::prelude::*;
use rustio::Station;
use libhandy::{ActionRow, ActionRowExt};

use std::rc::Rc;
use std::cell::RefCell;

pub struct Song {
    pub widget: ActionRow,
    pub title: String,
    pub duration: Rc<RefCell<u32>>, // in seconds
    recording: Rc<RefCell<bool>>,
}

impl Song {
    pub fn new(title: &str) -> Self {
        let widget = ActionRow::new();
        widget.show_all();
        widget.set_title(&title);
        widget.set_subtitle("");
        widget.set_icon_name("");

        let song = Self {
            widget,
            title: title.to_string(),
            duration: Rc::new(RefCell::new(0)),
            recording: Rc::new(RefCell::new(false)),
        };

        song.start();
        song
    }

    pub fn start(&self){
        *self.recording.borrow_mut() = true;

        let duration = self.duration.clone();
        let recording = self.recording.clone();
        gtk::timeout_add_seconds(1, move ||{
            *duration.borrow_mut() += 1;
            glib::Continue(*recording.borrow())
        });
    }

    pub fn stop(&self){
        *self.recording.borrow_mut() = false;

        let minutes = *self.duration.borrow() / 60;
        let seconds = *self.duration.borrow() % 60;
        self.widget.set_subtitle(&format!("{}:{}", minutes, seconds));
    }

    pub fn save(&self){
        // TODO: implement
    }

    pub fn delete(&self){
        // TODO: implement
    }
}
