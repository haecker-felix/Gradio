extern crate gtk;
use gtk::prelude::*;

use rustio::station::Station;
use std::sync::mpsc::Sender;
use app::Action;
use favicon_downloader::FaviconDownloader;
use gdk_pixbuf::Pixbuf;
use gtk::IconSize;
use glib::error::Error;

pub struct StationRow {
    pub container: gtk::Box,
    builder: gtk::Builder,
    sender: Sender<Action>,
    station: Station,
}

impl StationRow {
     pub fn new(station: &Station, sender: Sender<Action>) -> Self {
         let builder = gtk::Builder::new_from_string(include_str!("station_row.ui"));

         let container: gtk::Box = builder.get_object("station_row").unwrap();
         let station_label: gtk::Label = builder.get_object("station_label").unwrap();
         station_label.set_text(&station.name);

         let station_favicon: gtk::Image = builder.get_object("station_favicon").unwrap();
         let downloader = FaviconDownloader::new();
         match downloader.get_pixbuf(&station, 48){
            Some(p) => station_favicon.set_from_pixbuf(&p),
            None => station_favicon.set_from_icon_name("emblem-music-symbolic", 48),
         }

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