extern crate gtk;

use app_cache::AppCache;
use gtk::prelude::*;
use page::Page;
use rustio::AsyncClient;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use std::sync::mpsc::{channel, Sender};
use widgets::station_listbox::StationListBox;
use rustio::Station;
use rustio::Message;
use rustio::StationSearch;
use rustio::Task;

pub struct SearchPage {
    app_cache: AppCache,

    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
    result_listbox: Rc<RefCell<StationListBox>>,

    client_sender: Sender<Message>,
}

impl SearchPage {
    fn connect_signals(&self) {
        let mut search_entry: gtk::SearchEntry = self.builder.get_object("search_entry").unwrap();

        // create and start async client
        let mut async_client = RefCell::new(AsyncClient::new("http://www.radio-browser.info".to_string(), self.client_sender.clone()));
        async_client.borrow_mut().start_loop();

        search_entry.connect_search_changed(move |search_entry| {
            // Get search term
            let search_term = search_entry.get_text().unwrap();
            debug!("Search for {}", search_term);

            // create search task
            let search_data = StationSearch::search_for_name(search_term, false, 20);
            let task = Task::Search(search_data);

            // set task for async_client
            async_client.borrow_mut().set_task(task);
        });
    }
}

impl Page for SearchPage {
    fn new(app_cache: AppCache) -> Self {
        let title = "Search".to_string();
        let name = "search_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("search_page.ui"));
        let container: gtk::Box = builder.get_object("search_page").unwrap();

        let (client_sender, client_receiver) = channel();

        let result_listbox: Rc<RefCell<StationListBox>> = Rc::new(RefCell::new(StationListBox::new(app_cache.clone(), client_receiver)));
        let results_box: gtk::Box = builder.get_object("results_box").unwrap();
        let results_stack: gtk::Stack = builder.get_object("results_stack").unwrap();
        results_box.add(&result_listbox.borrow().container);

        let searchpage = SearchPage {
            app_cache,
            title,
            name,
            builder,
            container,
            result_listbox,
            client_sender,
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
