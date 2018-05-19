extern crate gtk;
use gtk::prelude::*;

use rustio::station::Station;
use std::sync::mpsc::Sender;
use app::Action;
use station_row::StationRow;

pub struct StationListBox {
    pub container: gtk::Box,
    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl StationListBox {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_listbox.ui"));

        let container: gtk::Box = builder.get_object("station_listbox").unwrap();

        Self {container, builder, sender}
    }

    pub fn show_stations(&self, stations: &Vec<Station>){
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();

        // Remove old list rows
        for row in listbox.get_children().iter() {
            listbox.remove(row);
        }

        for station in stations {
            let row = StationRow::new(&station, self.sender.clone());
            listbox.add(&row.container);
        }
    }
}