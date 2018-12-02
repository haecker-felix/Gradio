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
    listbox: gtk::ListBox,
    station_model: StationModel,
    content_type: ContentType,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl StationListBox {
    // TODO: remove title stuff from ui file
    pub fn new(sender: Sender<Action>, content_type: ContentType) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/station_listbox.ui");
        let widget: gtk::Box = builder.get_object("station_listbox").unwrap();
        let listbox: gtk::ListBox = builder.get_object("listbox").unwrap();
        let station_model = StationModel::new();

        Self { widget, listbox, station_model, content_type, builder, sender }
    }

    pub fn add_stations(&mut self, stations: Vec<Station>){
        self.station_model.add_stations(stations.clone());
        self.refresh();
    }

    pub fn remove_stations(&mut self, stations: Vec<Station>){
        self.station_model.remove_stations(stations);
        self.refresh();
    }

    pub fn get_stations(&self) -> Vec<Station>{
        self.station_model.export_vec()
    }

    fn refresh(&self){
        self.clear();
        for (id, station) in self.station_model.clone() {
            let row = StationRow::new(self.sender.clone(), station, self.content_type.clone());
            self.listbox.add(&row.widget);
        }
    }

    fn clear(&self) {
        for widget in self.listbox.get_children() {
            widget.destroy();
        }
    }
}
