extern crate gtk;
use gtk::prelude::*;

use page::Page;
use station_row::StationRow;
use std::rc::Rc;
use library::Library;

use rustio::station::Station;
use std::sync::mpsc::Sender;
use app::Action;
use std::collections::HashMap;
use favicon_downloader::FaviconDownloader;

pub struct LibraryPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
    station_listbox: gtk::ListBox,

    sender: Sender<Action>,
}

impl LibraryPage {
    pub fn update_stations(&self, stations: &HashMap<i32, Station>){
        let fdl = FaviconDownloader::new();
        for station in stations {
            let row = StationRow::new(&station.1, self.sender.clone(), &fdl);
            self.station_listbox.add(&row.container);
        }
    }
}

impl Page for LibraryPage {
    fn new(sender: Sender<Action>) -> Self {
        let title = "Library".to_string();
        let name = "library_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("library_page.ui"));
        let container: gtk::Box = builder.get_object("library_page").unwrap();
        let station_listbox: gtk::ListBox = builder.get_object("station_listbox").unwrap();

        Self { title, name, builder, container, station_listbox, sender }
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
