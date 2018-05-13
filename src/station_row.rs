extern crate gtk;
use gtk::prelude::*;

use rustio::station::Station;

pub struct StationRow {
    pub container: gtk::Box,
    pub play_button: gtk::Button,
    builder: gtk::Builder,
}

impl StationRow {
     pub fn new(station: &Station) -> Self {
         let builder = gtk::Builder::new_from_string(include_str!("station_row.ui"));

         let container: gtk::Box = builder.get_object("station_row").unwrap();
         let play_button: gtk::Button = builder.get_object("play_button").unwrap();
         let station_label: gtk::Label = builder.get_object("station_label").unwrap();
         station_label.set_text(&station.name);

         Self {container, play_button, builder}
    }
}