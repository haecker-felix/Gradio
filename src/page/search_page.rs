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
use std::sync::mpsc::channel;
use rustio::client::ClientUpdate;
use std::sync::mpsc::Receiver;
use std::cell::RefCell;

pub struct SearchPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
    result_listbox: Rc<StationListBox>,

    app_sender: Sender<Action>,

    client: Rc<RefCell<Client>>,
    client_sender: Sender<ClientUpdate>,
}

impl SearchPage {
    fn connect_signals(&self){
        let search_entry: gtk::SearchEntry = self.builder.get_object("search_entry").unwrap();
        let result_listbox = self.result_listbox.clone();
        let client = self.client.clone();
        let client_sender = self.client_sender.clone();

        search_entry.connect_search_changed(move|search_entry|{
            // Get search term
            let search_term = search_entry.get_text().unwrap();

            // prepare search params
            let mut params = HashMap::new();
            params.insert("name".to_string(), search_term);
            params.insert("limit".to_string(), "100".to_string());

            // do the search itself
            client.borrow_mut().search(params);
        });
    }
}

impl Page for SearchPage {
    fn new(app_sender: Sender<Action>) -> Self {
        let title = "Search".to_string();
        let name = "search_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("search_page.ui"));
        let container: gtk::Box = builder.get_object("search_page").unwrap();

        let result_listbox: Rc<StationListBox> = Rc::new(StationListBox::new(app_sender.clone()));
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

        let searchpage = SearchPage{ title, name, builder, container, result_listbox, app_sender, client, client_sender };
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
