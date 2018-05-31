extern crate gtk;
use gtk::prelude::*;

use page::Page;
use widgets::station_row::StationRow;
use std::rc::Rc;

use app::AppState;
use rustio::station::Station;
use std::cell::RefCell;
use std::collections::HashMap;

pub struct LibraryPage {
    app_state: Rc<RefCell<AppState>>,

    title: String,
    name: String,

    container: gtk::Box,
    station_listbox: gtk::ListBox,
}

impl LibraryPage {
    pub fn update_stations(&self, stations: &HashMap<i32, Station>) {
        for station in stations {
            let row = StationRow::new(self.app_state.clone(), &station.1);
            self.station_listbox.add(&row.container);
        }
    }
}

impl Page for LibraryPage {
    fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let title = "Library".to_string();
        let name = "library_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("library_page.ui"));
        let container: gtk::Box = builder.get_object("library_page").unwrap();
        let station_listbox: gtk::ListBox = builder.get_object("station_listbox").unwrap();

        Self {
            app_state,
            title,
            name,
            container,
            station_listbox,
        }
    }

    fn title(&self) -> &String {
        &self.title
    }

    fn name(&self) -> &String {
        &self.name
    }

    fn container(&self) -> &gtk::Box {
        &self.container
    }
}
