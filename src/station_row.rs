extern crate gtk;
use gtk::prelude::*;

use rustio::station::Station;
use std::sync::mpsc::Sender;
use app::Action;
use favicon_downloader::FaviconDownloader;
use gdk_pixbuf::Pixbuf;
use gtk::IconSize;
use glib::error::Error;
use std::thread;
use std::time::Duration;
use std::sync::mpsc::channel;
use std::path::Path;
use std::path::PathBuf;

pub struct StationRow {
    pub container: gtk::ListBoxRow,
    builder: gtk::Builder,
    sender: Sender<Action>,
    station: Station,
}

impl StationRow {
     pub fn new(station: &Station, sender: Sender<Action>, fdl: &FaviconDownloader) -> Self {
         let builder = gtk::Builder::new_from_string(include_str!("station_row.ui"));

         let container: gtk::ListBoxRow = builder.get_object("station_row").unwrap();
         let favicon_image: gtk::Image = builder.get_object("station_favicon").unwrap();
         let station_label: gtk::Label = builder.get_object("station_label").unwrap();
         station_label.set_text(&station.name);

         fdl.set_favicon_async(favicon_image, &station, 32);

         let row = Self {container, builder, sender, station: station.clone()};
         row.connect_signals();
         row
    }

    fn connect_signals(&self){
         let play_button: gtk::Button = self.builder.get_object("play_button").unwrap();
         let station = self.station.clone();
         let sender = self.sender.clone();
         play_button.connect_clicked(move|_|{
             let station = station.clone();
             sender.send(Action::PlaybackSetStation(station));
             sender.send(Action::PlaybackStart);
         });

    }
}