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
use station_listbox::StationListBox;
use std::collections::HashMap;

pub struct SearchPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
    result_listbox: Rc<StationListBox>,

    sender: Sender<Action>,
}

impl SearchPage {
    fn connect_signals(&self){
        let search_button: gtk::Button = self.builder.get_object("search_button").unwrap();
        let search_entry: gtk::Entry = self.builder.get_object("search_entry").unwrap();
        let result_listbox = self.result_listbox.clone();

        search_button.connect_clicked(move|_|{
            let client = Client::new();

            // Get search term
            let search_term = search_entry.get_text().unwrap();
            search_entry.set_text("");

            // prepare search params
            let mut params = HashMap::new();
            params.insert("name".to_string(), search_term);
            params.insert("limit".to_string(), "250".to_string());

            // do the search itself
            debug!("Search for: {:?}", params);
            let result = client.search(&params);

            // show results
            result_listbox.show_stations(&result);
        });
    }
}

impl Page for SearchPage {
    fn new(sender: Sender<Action>) -> Self {
        let title = "Search".to_string();
        let name = "search_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("search_page.ui"));
        let container: gtk::Box = builder.get_object("search_page").unwrap();

        let result_listbox: Rc<StationListBox> = Rc::new(StationListBox::new(sender.clone()));
        let results_box: gtk::Box = builder.get_object("results_box").unwrap();
        results_box.add(&result_listbox.container);

        let searchpage = SearchPage{ title, name, builder, container, result_listbox, sender };
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
