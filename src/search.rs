use gtk::prelude::*;
use libhandy::{Leaflet, LeafletChildTransitionType, LeafletExt, LeafletModeTransitionType};
use rustio::{Client, StationSearch};

use std::sync::mpsc::Sender;
use std::cell::RefCell;

use crate::widgets::station_listbox::StationListBox;
use crate::widgets::station_row::ContentType;
use crate::app::Action;

pub struct Search {
    pub widget: gtk::Box,
    station_listbox: RefCell<StationListBox>,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Search {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/search.ui");
        let widget: gtk::Box = builder.get_object("search").unwrap();

        let results_box: gtk::Box = builder.get_object("results_box").unwrap();
        let station_listbox = RefCell::new(StationListBox::new(sender.clone(), ContentType::Other));
        results_box.add(&station_listbox.borrow().widget);

        let search = Self { widget, station_listbox, builder, sender };

        search.setup_signals();
        search
    }

    pub fn search_for(&self, data: StationSearch){
        debug!("search for: {:?}", data);

        let mut client = Client::new("http://www.radio-browser.info");
        let result = client.search(data).unwrap();

        self.station_listbox.borrow_mut().clear();
        self.station_listbox.borrow_mut().add_stations(result);
    }

    fn setup_signals(&self) {
        let search_entry: gtk::SearchEntry = self.builder.get_object("search_entry").unwrap();
        let sender = self.sender.clone();
        search_entry.connect_search_changed(move|entry|{
            let data = StationSearch::search_for_name(entry.get_text().unwrap(), false, 100);
            sender.send(Action::SearchFor(data)).unwrap();
        });
    }
}
