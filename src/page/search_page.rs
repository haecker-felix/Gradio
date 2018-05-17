extern crate gtk;
use gtk::prelude::*;

use page::Page;
use station_row::StationRow;
use std::rc::Rc;
use library::Library;

use rustio::station::Station;
use rustio::client::Client;
use std::sync::mpsc::Sender;
use app::Action;
use std::collections::HashMap;

pub struct SearchPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,

    sender: Sender<Action>,
}

impl SearchPage {
    fn connect_signals(&self){
        let search_button: gtk::Button = self.builder.get_object("search_button").unwrap();
        let search_entry: gtk::Entry = self.builder.get_object("search_entry").unwrap();
        let station_listbox: gtk::ListBox = self.builder.get_object("station_listbox").unwrap();
        let sender = self.sender.clone();

        search_button.connect_clicked(move|_|{
            let search_term = search_entry.get_text().unwrap();
            search_entry.set_text("");

            let client = Client::new();

            let mut params = HashMap::new();
            params.insert("name".to_string(), search_term);

            info!("search for: {:?}", params);
            let result = client.search(&params);

            for station in result {
                info!("result: {}", station.name   );
                let row = StationRow::new(&station, sender.clone());
                station_listbox.add(&row.container);
            }
        });
    }
}

impl Page for SearchPage {
    fn new(sender: Sender<Action>) -> Self {
        let title = "Search".to_string();
        let name = "search_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("search_page.ui"));
        let container: gtk::Box = builder.get_object("search_page").unwrap();

        let searchpage = SearchPage{ title, name, builder, container, sender };
        searchpage.connect_signals();
        searchpage
    }

    fn title(&self) -> &String {
        &self.title
    }

    fn name(&self) -> &String {
        &self.name
    }

    fn container(&self) -> &gtk::Box {
        &self.container
    }
}
