extern crate gio;
extern crate gtk;
use gtk::prelude::*;

use rustio::Station;
use std::sync::mpsc::Sender;
use std::collections::HashMap;

use app::Action;
use widgets::station_row::{StationRow, ContentType};
use station_model::StationModel;

pub struct StationListBox {
    pub widget: gtk::Box,
    content_type: ContentType,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl StationListBox {
    pub fn new(sender: Sender<Action>, title: &str, content_type: ContentType) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/station_listbox.ui");
        let listbox: gtk::Box = builder.get_object("station_listbox").unwrap();

        if(title != ""){
            let title_label: gtk::Label = builder.get_object("title_label").unwrap();
            title_label.set_text(title);
            title_label.set_visible(true);
        }

        let stationlistbox = Self { widget: listbox, content_type, builder, sender };

        stationlistbox
    }

    pub fn set_stations(&self, stations: HashMap<u32, Station>) {
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();

        // remove all previous rows
        for widget in listbox.get_children() {
            widget.destroy();
        }

        for (id, station) in stations {
            let row = StationRow::new(self.sender.clone(), station, self.content_type.clone());
            listbox.add(&row.widget);
        }
    }
}
