use gtk::prelude::*;
use libhandy::{Leaflet, LeafletChildTransitionType, LeafletExt, LeafletModeTransitionType};

use std::sync::mpsc::Sender;

use crate::app::Action;

pub struct Search {
    pub widget: gtk::Box,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Search {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/search.ui");
        let widget: gtk::Box = builder.get_object("search").unwrap();

        let search = Self { widget, builder, sender };

        search.setup_signals();
        search
    }

    fn setup_signals(&self) {
        let search_entry: gtk::SearchEntry = self.builder.get_object("search_entry").unwrap();
        search_entry.connect_search_changed(move|_|{
            debug!("search changed");
        });
    }
}
