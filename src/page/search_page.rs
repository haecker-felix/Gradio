extern crate gtk;
use gtk::prelude::*;

use page::Page;
use station_row::StationRow;
use std::rc::Rc;
use library::Library;

use rustio::station::Station;
use rustio::client::Client;
use std::sync::mpsc::Sender;
use station_listbox::StationListBox;
use std::collections::HashMap;
use std::sync::mpsc::channel;
use rustio::client::ClientUpdate;
use std::sync::mpsc::Receiver;
use std::cell::RefCell;
use app::AppState;

pub struct SearchPage {
    app_state: Rc<RefCell<AppState>>,

    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
    result_listbox: Rc<StationListBox>,
}

impl SearchPage {
    fn connect_signals(&self){
        let search_entry: gtk::SearchEntry = self.builder.get_object("search_entry").unwrap();
        let result_listbox = self.result_listbox.clone();
        let app_state = self.app_state.clone();

        search_entry.connect_search_changed(move|search_entry|{
            // Get search term
            let search_term = search_entry.get_text().unwrap();

            // prepare search params
            let mut params = HashMap::new();
            params.insert("name".to_string(), search_term);
            params.insert("limit".to_string(), "100".to_string());

            // do the search itself
            app_state.borrow_mut().client.search(params);
        });
    }
}

impl Page for SearchPage {
    fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let title = "Search".to_string();
        let name = "search_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("search_page.ui"));
        let container: gtk::Box = builder.get_object("search_page").unwrap();

        let result_listbox: Rc<StationListBox> = Rc::new(StationListBox::new(app_state.clone()));
        let results_box: gtk::Box = builder.get_object("results_box").unwrap();
        let results_stack: gtk::Stack = builder.get_object("results_stack").unwrap();
        results_box.add(&result_listbox.container);

        let (client_sender, client_receiver) = channel();
        let client = Rc::new(RefCell::new(Client::new_with_sender((client_sender.clone()))));

        let result_listbox_clone = result_listbox.clone();
        gtk::timeout_add(100, move || {
            match client_receiver.try_recv() {
                Ok(ClientUpdate::NewStations(stations)) => {
                    result_listbox_clone.add_stations(&stations);
                    results_stack.set_visible_child_name("results");
                },
                Ok(ClientUpdate::Clear) => {
                    results_stack.set_visible_child_name("loading");
                    result_listbox_clone.clear();
                },
                Err(err) => (),
            }
            Continue(true)
        });

        let searchpage = SearchPage{ app_state, title, name, builder, container, result_listbox };
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
