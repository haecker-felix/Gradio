extern crate gtk;
use gtk::prelude::*;

use app_cache::AppCache;
use rustio::station::Station;
use std::cell::RefCell;
use std::rc::Rc;
use widgets::station_row::StationRow;
use gtk::WidgetExt;
use libhandy::{Column, ColumnExt};
use std::collections::HashMap;

pub struct StationListBox {
    app_cache: AppCache,

    pub container: gtk::Box,
    builder: gtk::Builder,

    // We need to track which station is which listboxrow, otherwise we cannot remove them
    // station_id (string), StationRow
    station_rows: HashMap<String, StationRow>,
}

impl StationListBox {
    pub fn new(app_cache: AppCache) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_listbox.ui"));
        let container: gtk::Box = builder.get_object("station_listbox").unwrap();

        let column: Column = builder.get_object("column").unwrap();
        column.set_maximum_width(600);

        let mut station_rows = HashMap::new();

        Self { app_cache, container, builder, station_rows }
    }

    pub fn set_title(&self, title: String) {
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        title_label.set_text(&title);
        title_label.set_visible(true);
    }

    pub fn clear(&mut self) {
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        for row in listbox.get_children().iter() {
            listbox.remove(row);
        }
        self.station_rows.clear();
    }

    pub fn add_station(&mut self, station: &Station){
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        let row = StationRow::new(self.app_cache.clone(), &station);
        listbox.add(&row.container);
        self.station_rows.insert(station.id.clone(), row);
    }

    pub fn remove_station(&mut self, station: &Station){
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        match self.station_rows.remove(&station.id) {
            Some(row) => {
                listbox.remove(&row.container);
            },
            None => warn!("Cannot remove not existing row."),
        };
    }
}
