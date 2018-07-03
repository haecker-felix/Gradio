extern crate gtk;
use gtk::prelude::*;

use app::AppState;
use rustio::station::Station;
use std::cell::RefCell;
use std::rc::Rc;

pub struct StationRow {
    app_state: Rc<RefCell<AppState>>,
    pub container: gtk::ListBoxRow,
    builder: gtk::Builder,
    station: Station,
}

impl StationRow {
    pub fn new(app_state: Rc<RefCell<AppState>>, station: &Station) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_row.ui"));

        let container: gtk::ListBoxRow = builder.get_object("station_row").unwrap();
        let favicon_image: gtk::Image = builder.get_object("station_favicon").unwrap();

        let station_label: gtk::Label = builder.get_object("station_label").unwrap();
        let votes_label: gtk::Label = builder.get_object("votes_label").unwrap();
        let location_label: gtk::Label = builder.get_object("location_label").unwrap();
        let codec_label: gtk::Label = builder.get_object("codec_label").unwrap();
        let homepage_label: gtk::Label = builder.get_object("homepage_label").unwrap();
        let tags_label: gtk::Label = builder.get_object("tags_label").unwrap();
        let language_label: gtk::Label = builder.get_object("language_label").unwrap();

        station_label.set_text(&station.name);
        votes_label.set_text(&format!("{} Votes", station.votes));
        location_label.set_text(&format!("{} {}", station.country, station.state));
        codec_label.set_text(&station.codec);

        if station.homepage != "" {homepage_label.set_markup(&format!("<a href=\"{}\">{}</a>", station.homepage, station.homepage));
        }else{homepage_label.set_text("—");}

        if station.tags != "" {tags_label.set_text(&station.tags);
        }else{tags_label.set_text("—");}

        if station.language != "" {language_label.set_text(&station.language);
        }else{language_label.set_text("—");}

        app_state.borrow().fdl.set_favicon_async(&favicon_image, &station, 32);

        let row = Self {
            app_state,
            container,
            builder,
            station: station.clone(),
        };
        row.connect_signals();
        row
    }

    fn connect_signals(&self) {
        let play_button: gtk::Button = self.builder.get_object("play_button").unwrap();
        let station = self.station.clone();
        let app_state = self.app_state.clone();
        play_button.connect_clicked(move |_| {
            let station = station.clone();
            app_state.borrow_mut().player.set_station(station);
            app_state.borrow_mut().player.set_playback(true);
        });

        let play_button: gtk::Button = self.builder.get_object("play_button").unwrap();
        let station = self.station.clone();
        let app_state = self.app_state.clone();
        play_button.connect_clicked(move |_| {
            let station = station.clone();
            app_state.borrow_mut().player.set_station(station);
            app_state.borrow_mut().player.set_playback(true);
        });

        let eventbox: gtk::EventBox = self.builder.get_object("eventbox").unwrap();
        let revealer: gtk::Revealer = self.builder.get_object("revealer").unwrap();
        eventbox.connect_button_press_event(move |_,_| {
            revealer.set_reveal_child(!revealer.get_reveal_child());
            gtk::Inhibit(true)
        });
    }
}
