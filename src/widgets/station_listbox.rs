extern crate gtk;
use gtk::prelude::*;

use app_cache::AppCache;
use rustio::Station;
use widgets::station_row::StationRow;
use gtk::WidgetExt;
use std::collections::HashMap;
use std::rc::Rc;
use favicon_downloader::FaviconDownloader;
use rustio::Message;
use std::sync::mpsc::Receiver;
use std::cell::RefCell;

pub struct StationListBox {
    app_cache: AppCache,

    pub container: gtk::Box,
    builder: gtk::Builder,

    fdl: Rc<FaviconDownloader>,
    receiver: Rc<Receiver<Message>>,

    // We need to track which station is which listboxrow, otherwise we cannot remove them
    // station_id (string), StationRow
    station_rows: Rc<RefCell<HashMap<String, StationRow>>>,
}

impl StationListBox {
    pub fn new(app_cache: AppCache, client_receiver: Receiver<Message>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_listbox.ui"));
        let container: gtk::Box = builder.get_object("station_listbox").unwrap();

        let fdl = Rc::new(FaviconDownloader::new());
        let receiver = Rc::new(client_receiver);

        let mut station_rows = Rc::new(RefCell::new(HashMap::new()));

        let slb = Self { app_cache, container, builder, fdl, receiver, station_rows };
        slb.start_loop();
        slb
    }

    pub fn set_title(&self, title: String) {
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        title_label.set_text(&title);
        title_label.set_visible(true);
    }

    fn start_loop(&self){
        let listbox: gtk::ListBox = self.builder.get_object("listbox").unwrap();
        let receiver = self.receiver.clone();
        let station_rows = self.station_rows.clone();
        let app_cache = self.app_cache.clone();
        let fdl = self.fdl.clone();

        gtk::timeout_add(100, move || {
            match receiver.try_recv() {
                // Insert new rows
                Ok(Message::StationAdd(stations)) => {
                    for station in stations{
                        let row = StationRow::new(app_cache.clone(), &station, fdl.clone());
                        listbox.add(&row.container);
                        station_rows.borrow_mut().insert(station.id.clone(), row);
                    }
                }

                // Remove rows
                Ok(Message::StationAdd(stations)) => {
                    for station in stations{
                        match station_rows.borrow_mut().remove(&station.id) {
                            Some(row) => listbox.remove(&row.container),
                            None => warn!("Cannot remove not existing row."),
                        };
                    }
                }

                // Clear all rows
                Ok(Message::Clear) => {
                    for row in listbox.get_children().iter() {
                        listbox.remove(row);
                    }
                    station_rows.borrow_mut().clear();
                }
                Ok(_) => (),
                Err(_) => (),
            }
            Continue(true)
        });
    }
}
