extern crate gio;
extern crate gtk;
use gtk::prelude::*;

use rustio::Station;
use std::collections::HashMap;
use std::sync::mpsc::Sender;

use app::Action;
use widgets::station_listbox::StationListBox;

pub struct CollectionListBox {
    pub widget: gtk::ListBox,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl CollectionListBox {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/collection_listbox.ui");
        let listbox: gtk::ListBox = builder.get_object("collection_listbox").unwrap();

        let collection_listbox = Self { widget: listbox, builder, sender };

        collection_listbox
    }

    pub fn set_collections(&self, collections: &HashMap<String, Vec<Station>>) {
        // remove all previous rows
        for widget in self.widget.get_children() {
            widget.destroy();
        }

        for (title, stations) in collections {
            let listbox = StationListBox::new(self.sender.clone(), &title);
            listbox.set_stations(stations.clone());

            let row = gtk::ListBoxRow::new();
            row.add(&listbox.widget);
            row.set_activatable(false);
            row.show_all();
            self.widget.add(&row);
        }
    }
}
