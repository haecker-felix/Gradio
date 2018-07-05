extern crate gtk;

use app::AppState;
use gtk::prelude::*;
use gtk::Builder;
use page::Page;
use rustio::station::Station;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use widgets::station_row::StationRow;
use widgets::station_listbox::StationListBox;

pub struct LibraryPage {
    app_state: Rc<RefCell<AppState>>,

    title: String,
    name: String,
    builder: Builder,

    container: gtk::Box,
    station_listboxes: HashMap<i32, StationListBox>,
}

impl LibraryPage {
    pub fn update_stations(&mut self, stations: &HashMap<i32, (Station, i32)>) {
        for station in stations {
            let collection_id = (station.1).1;
            let station = &(station.1).0;

            // check if listbox for collection already exists...
            let new_station_listbox = match self.station_listboxes.get(&collection_id) {
                Some(station_listbox) => { // yes -> just add the station...
                    station_listbox.add_station(&station);
                    None
                },
                None => { // no -> create new listbox, add station, and return it...
                    debug!("Create new listbox container...");
                    let station_listbox = StationListBox::new(self.app_state.clone());
                    station_listbox.set_title(collection_id.to_string());
                    station_listbox.add_station(&station);
                    Some(station_listbox)
                }
            };

            // optionally add new listbox to boxes hashmap
            if new_station_listbox.is_some(){ self.station_listboxes.insert(collection_id, new_station_listbox.unwrap()); }
        }

        // Add listboxes to the page itself
        let library_box: gtk::Box = self.builder.get_object("library_box").unwrap();
        for listbox in &self.station_listboxes {
            library_box.add(&(listbox.1).container);
        }
    }
}

impl Page for LibraryPage {
    fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let title = "Library".to_string();
        let name = "library_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("library_page.ui"));
        let container: gtk::Box = builder.get_object("library_page").unwrap();
        let mut station_listboxes: HashMap<i32, StationListBox> = HashMap::new();

        Self {
            app_state,
            title,
            name,
            builder,
            container,
            station_listboxes,
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
