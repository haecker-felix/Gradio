extern crate gtk;
use gtk::prelude::*;

use app::AppState;
use rustio::station::Station;
use std::cell::RefCell;
use std::rc::Rc;
use widgets::station_row::StationRow;
use gtk::WidgetExt;
use libhandy::{Column, ColumnExt};

pub struct StationListBox {
    app_state: Rc<RefCell<AppState>>,

    pub container: gtk::Box,
    builder: gtk::Builder,
}

impl StationListBox {
    pub fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_listbox.ui"));
        let container: gtk::Box = builder.get_object("station_listbox").unwrap();

        let column: Column = builder.get_object("column").unwrap();
        column.set_maximum_width(600);

        Self { app_state, container, builder }
    }

    pub fn set_title(&self, title: String) {
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        title_label.set_text(&title);
        title_label.set_visible(true);
    }

    pub fn clear(&self) {
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        for row in listbox.get_children().iter() {
            listbox.remove(row);
        }
    }

    pub fn add_station(&self, station: &Station){
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        let row = StationRow::new(self.app_state.clone(), &station);
        listbox.add(&row.container);
    }

    pub fn remove_station(&self, station: &Station){
        unimplemented!();
    }
}
