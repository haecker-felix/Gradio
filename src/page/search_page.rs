extern crate gtk;

use app_cache::AppCache;
use gtk::prelude::*;
use page::Page;
use rustio::client::ClientUpdate;
use rustio::client::Client;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use std::sync::mpsc::{channel, Sender};
use widgets::station_listbox::StationListBox;

pub struct SearchPage {
    app_cache: AppCache,

    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
    result_listbox: Rc<RefCell<StationListBox>>,

    search_sender: Sender<ClientUpdate>,
}

impl SearchPage {
    fn connect_signals(&self) {
        let mut client = Rc::new(RefCell::new(Client::new()));
        let search_entry: gtk::SearchEntry = self.builder.get_object("search_entry").unwrap();
        let search_sender = self.search_sender.clone();

        search_entry.connect_search_changed(move |search_entry| {
            // Get search term
            let search_term = search_entry.get_text().unwrap();

            // prepare search params
            let mut params = HashMap::new();
            params.insert("name".to_string(), search_term);
            params.insert("limit".to_string(), "150".to_string());

            // do the search itself
            client.borrow_mut().search(params, search_sender.clone());
        });
    }
}

impl Page for SearchPage {
    fn new(app_cache: AppCache) -> Self {
        let title = "Search".to_string();
        let name = "search_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("search_page.ui"));
        let container: gtk::Box = builder.get_object("search_page").unwrap();

        let result_listbox: Rc<RefCell<StationListBox>> = Rc::new(RefCell::new(StationListBox::new(app_cache.clone())));
        let results_box: gtk::Box = builder.get_object("results_box").unwrap();
        let results_stack: gtk::Stack = builder.get_object("results_stack").unwrap();
        results_box.add(&result_listbox.borrow().container);

        let (search_sender, search_receiver) = channel();

        let result_listbox_clone = result_listbox.clone();
        gtk::timeout_add(100, move || {
            match search_receiver.try_recv() {
                Ok(ClientUpdate::NewStations(stations)) => {
                    for station in stations {
                        result_listbox_clone.borrow_mut().add_station(&station);
                    }
                    results_stack.set_visible_child_name("results");
                }
                Ok(ClientUpdate::Clear) => {
                    results_stack.set_visible_child_name("loading");
                    result_listbox_clone.borrow_mut().clear();
                }
                Err(_) => (),
            }
            Continue(true)
        });

        let searchpage = SearchPage {
            app_cache,
            title,
            name,
            builder,
            container,
            result_listbox,
            search_sender,
        };
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
