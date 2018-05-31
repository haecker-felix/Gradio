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
        station_label.set_text(&station.name);

        app_state.borrow().fdl.set_favicon_async(favicon_image, &station, 32);

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
            app_state.borrow().player.set_station(&station);
            app_state.borrow().player.set_playback(true);
        });
    }
}
