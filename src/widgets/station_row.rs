extern crate gio;
extern crate gtk;
use gtk::prelude::*;

use rustio::Station;
use std::sync::mpsc::Sender;

use app::Action;

#[derive(Clone)]
pub enum ContentType{
    Library,
    Other,
}

pub struct StationRow {
    pub widget: gtk::ListBoxRow,
    station: Station,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl StationRow {
    pub fn new(sender: Sender<Action>, station: Station, ctype: ContentType) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/station_row.ui");
        let row: gtk::ListBoxRow = builder.get_object("station_row").unwrap();

        let stationrow = Self {
            widget: row,
            station,
            builder,
            sender,
        };

        let library_action_stack: gtk::Stack = stationrow.builder.get_object("library_action_stack").unwrap();
        match ctype{
            ContentType::Library => library_action_stack.set_visible_child_name("library-remove"),
            ContentType::Other => library_action_stack.set_visible_child_name("library-add"),
        }

        stationrow.setup_signals();
        stationrow.setup_widget();
        stationrow
    }

    fn setup_widget(&self) {
        let station_label: gtk::Label = self.builder.get_object("station_label").unwrap();
        let votes_label: gtk::Label = self.builder.get_object("votes_label").unwrap();
        let location_label: gtk::Label = self.builder.get_object("location_label").unwrap();
        let codec_label: gtk::Label = self.builder.get_object("codec_label").unwrap();
        let homepage_label: gtk::Label = self.builder.get_object("homepage_label").unwrap();
        let tags_label: gtk::Label = self.builder.get_object("tags_label").unwrap();
        let language_label: gtk::Label = self.builder.get_object("language_label").unwrap();

        station_label.set_text(&self.station.name);
        votes_label.set_text(&format!("{} Votes", self.station.votes));
        location_label.set_text(&format!("{} {}", self.station.country, self.station.state));
        codec_label.set_text(&self.station.codec);
    }

    fn setup_signals(&self) {
        // play_button
        let play_button: gtk::Button = self.builder.get_object("play_button").unwrap();
        let sender = self.sender.clone();
        let station = self.station.clone();
        play_button.connect_clicked(move |_| {
            sender.send(Action::PlaybackSetStation(station.clone())).unwrap();
        });

        // remove_button
        let remove_button: gtk::Button = self.builder.get_object("remove_button").unwrap();
        let sender = self.sender.clone();
        let station = self.station.clone();
        remove_button.connect_clicked(move |btn| {
            sender.send(Action::LibraryRemoveStations(vec![station.clone()])).unwrap();
            btn.set_sensitive(false);
        });

        // add_button
        let add_button: gtk::Button = self.builder.get_object("add_button").unwrap();
        let sender = self.sender.clone();
        let station = self.station.clone();
        add_button.connect_clicked(move |btn| {
            sender.send(Action::LibraryAddStations(vec![station.clone()])).unwrap();
            btn.set_sensitive(false);
        });

        // eventbox
        let eventbox: gtk::EventBox = self.builder.get_object("eventbox").unwrap();
        let check_button: gtk::CheckButton = self.builder.get_object("check_button").unwrap();
        let revealer: gtk::Revealer = self.builder.get_object("revealer").unwrap();
        eventbox.connect_button_press_event(move |_, button| {
            // 3 -> Right mouse button
            if button.get_button() == 3 {
                // TODO: enable selection mode
                check_button.set_active(true);
            } else {
                // TODO: handle selection mode - check_button.set_active(!check_button.get_active());
                revealer.set_reveal_child(!revealer.get_reveal_child());
            }
            gtk::Inhibit(false)
        });
    }
}
