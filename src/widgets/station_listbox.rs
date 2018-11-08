extern crate gtk;
extern crate gio;
use gtk::prelude::*;

use std::sync::mpsc::Sender;
use rustio::Station;

use app::Action;
use widgets::station_row::StationRow;

pub struct StationListBox{
    pub widget: gtk::Box,
    
    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl StationListBox{
    pub fn new(sender: Sender<Action>, title: &str) -> Self{
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/station_listbox.ui");
        let listbox: gtk::Box = builder.get_object("station_listbox").unwrap();
    
        let title_label: gtk::Label = builder.get_object("title_label").unwrap();
        title_label.set_text(title);
    
        let stationlistbox = Self{
            widget: listbox,
            builder,
            sender,
        };
        
        stationlistbox
    }
    
    pub fn set_stations(&self, stations: Vec<Station>){
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
    
        // remove all previous rows
        for widget in listbox.get_children(){
            widget.destroy();
        }
    
        for station in stations{
            let row = StationRow::new(self.sender.clone(), station);
            listbox.add(&row.widget);
        }
    }
}
