use gtk::prelude::*;
use rustio::Station;
use libhandy::{Column, ColumnExt};

use std::sync::mpsc::Sender;

use crate::app::Action;
use crate::station_model::{Order, Sorting, StationModel};
use crate::widgets::station_row::{ContentType, StationRow};

pub struct StationListBox {
    pub widget: gtk::Box,
    listbox: gtk::ListBox,
    station_model: StationModel,
    content_type: ContentType,

    sender: Sender<Action>,
}

impl StationListBox {
    pub fn new(sender: Sender<Action>, content_type: ContentType) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/station_listbox.ui");
        let widget: gtk::Box = builder.get_object("station_listbox").unwrap();
        let listbox: gtk::ListBox = builder.get_object("listbox").unwrap();
        let station_model = StationModel::new();

        // Setup HdyColumn
        let column = Column::new();
        column.set_maximum_width(700);
        widget.add(&column);
        let column = column.upcast::<gtk::Widget>(); // See https://gitlab.gnome.org/World/podcasts/blob/master/podcasts-gtk/src/widgets/home_view.rs#L64
        let column = column.downcast::<gtk::Container>().unwrap();
        column.show();
        column.add(&listbox);

        Self {
            widget,
            listbox,
            station_model,
            content_type,
            sender,
        }
    }

    pub fn add_stations(&mut self, stations: Vec<Station>) {
        for station in stations {
            match self.station_model.add_station(station.clone()) {
                Some(index) => {
                    let row = StationRow::new(self.sender.clone(), station, self.content_type.clone());
                    self.listbox.insert(&row.widget, index as i32);
                }
                None => (),
            }
        }
    }

    pub fn remove_stations(&mut self, stations: Vec<Station>) {
        for station in stations {
            match self.station_model.remove_station(station) {
                Some(index) => {
                    let row = self.listbox.get_row_at_index(index as i32).unwrap();
                    self.listbox.remove(&row);
                }
                None => (),
            }
        }
    }

    pub fn get_stations(&self) -> Vec<Station> {
        self.station_model.export_vec()
    }

    pub fn set_sorting(&mut self, sorting: Sorting, order: Order) {
        self.station_model.set_sorting(sorting, order);
        self.station_model.sort();
        self.refresh();
    }

    fn refresh(&self) {
        // remove all rows
        for widget in self.listbox.get_children() {
            widget.destroy();
        }

        // sort
        for (_, station) in self.station_model.clone() {
            let row = StationRow::new(self.sender.clone(), station, self.content_type.clone());
            self.listbox.add(&row.widget);
        }
    }

    pub fn clear(&mut self) {
        // remove all rows
        for widget in self.listbox.get_children() {
            widget.destroy();
        }

        // clear station_model
        self.station_model.clear();
    }
}
