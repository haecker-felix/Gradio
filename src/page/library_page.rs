extern crate gtk;
use gtk::prelude::*;

use page::Page;
use station_row::StationRow;
use std::rc::Rc;
use library::Library;

use rustio::station::Station;

pub struct LibraryPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
}

impl LibraryPage {
    pub fn init(&self, library: &Library){
        let station_listbox: gtk::ListBox = self.builder.get_object("station_listbox").unwrap();

        for station in &library.stations {
            let row = StationRow::new(&station.1);
            station_listbox.add(&row.container);
        }
    }
}

impl Page for LibraryPage {
    fn new() -> Self {
        let title = "Library".to_string();
        let name = "library_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("library_page.ui"));
        let container: gtk::Box = builder.get_object("library_page").unwrap();

        Self { title, name, builder, container }
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
