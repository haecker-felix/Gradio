use gtk::prelude::*;
use rustio::Station;
use libhandy::{ActionRow, ActionRowExt};

pub struct Song {
    pub widget: ActionRow,
    pub title: String,
}

impl Song {
    pub fn new(title: &str) -> Self {
        let widget = ActionRow::new();
        widget.show_all();
        widget.set_title(&title);
        widget.set_subtitle("");
        widget.set_icon_name("");

        Self {
            widget,
            title: title.to_string(),
        }
    }
}
