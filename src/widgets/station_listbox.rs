extern crate gtk;
use gtk::prelude::*;

use app::AppState;
use rustio::station::Station;
use std::cell::RefCell;
use std::rc::Rc;
use widgets::station_row::StationRow;

pub struct StationListBox {
    app_state: Rc<RefCell<AppState>>,

    pub container: gtk::Box,
    builder: gtk::Builder,
}

impl StationListBox {
    pub fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_listbox.ui"));

        let container: gtk::Box = builder.get_object("station_listbox").unwrap();

        Self { app_state, container, builder }
    }

    pub fn clear(&self) {
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        for row in listbox.get_children().iter() {
            listbox.remove(row);
        }
    }

    pub fn add_stations(&self, stations: &Vec<Station>) {
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        for station in stations {
            let row = StationRow::new(self.app_state.clone(), &station);
            listbox.add(&row.container);
        }
    }
}
