extern crate gtk;

use app_cache::AppCache;
use app_state::AppState;
use mdl::Model;
use gtk::prelude::*;
use gtk::Builder;
use page::Page;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use widgets::station_listbox::StationListBox;

pub struct LibraryPage {
    app_cache: AppCache,

    title: String,
    name: String,
    builder: Builder,

    container: gtk::Box,
    station_listboxes: Rc<RefCell<HashMap<Option<String>, StationListBox>>>, // Collection Name & StationListBox
}

impl LibraryPage {
    pub fn connect_signals(&mut self) {
        // Connect to "library" signal
        let app_cache = self.app_cache.clone();
        let station_listboxes = self.station_listboxes.clone();
        let library_box: gtk::Box = self.builder.get_object("library_box").unwrap();
        self.app_cache.signaler.subscribe("library", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

            for (station, collection_name) in &app_state.library.stations {
                match station_listboxes.borrow_mut().get_mut(&collection_name) {
                    Some(station_listbox) => /*station_listbox.add_station(&station)*/(),
                    None => {
                        //let mut station_listbox = StationListBox::new(app_cache.clone());
                        //station_listbox.set_title("name".to_string());
                        //station_listbox.add_station(&station);
                        //library_box.add(&station_listbox.container);
                    },
                };
            }
        })).unwrap();




        // let app_state = self.app_state.clone();

        // self.app_state.borrow_mut().library.register_update_callback(move|update|{
        //     match(update){

                // Add new station //
        //         Update::StationAdded(station, collection_id) => {
        //             match station_listboxes.borrow_mut().get_mut(&collection_id) {
        //                 Some(station_listbox) => station_listbox.add_station(&station),
        //                 None => warn!("Could not find collection: {}", collection_id),
        //             };
        //         },

                // Remove Station //
        //         Update::StationRemoved(station, collection_id) => {
        //             match station_listboxes.borrow_mut().get_mut(&collection_id) {
        //                 Some(station_listbox) => station_listbox.remove_station(&station),
        //                 None => warn!("Could not find collection: {}", collection_id),
        //             };
        //         },

                // Add Collection //
        //         Update::CollectionAdded(collection_id, collection_name) => {
        //             if station_listboxes.borrow_mut().get_mut(&collection_id).is_none() {
        //                 let station_listbox = StationListBox::new(app_state.clone());
        //                 station_listbox.set_title(collection_name);
        //                 library_box.add(&station_listbox.container);
        //                 station_listboxes.borrow_mut().insert(collection_id, station_listbox);
        //             }
        //         }

                // Remove Collection //
        //         Update::CollectionRemoved(collection_id) => {
        //             match station_listboxes.borrow_mut().get_mut(&collection_id) {
        //                 Some(station_listbox) => {
        //                     station_listbox.clear();
        //                     library_box.remove(&station_listbox.container);
        //                     station_listboxes.borrow_mut().remove(&collection_id);
        //                 }
        //                 None => warn!("Could not find collection: {}", collection_id),
        //             };
        //         },
        //     }
        // });
    }
}

impl Page for LibraryPage {
    fn new(app_cache: AppCache) -> Self {
        let title = "Library".to_string();
        let name = "library_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("library_page.ui"));
        let container: gtk::Box = builder.get_object("library_page").unwrap();
        let mut station_listboxes: Rc<RefCell<HashMap<Option<String>, StationListBox>>> = Rc::new(RefCell::new(HashMap::new()));

        let mut library_page = Self {
            app_cache,
            title,
            name,
            builder,
            container,
            station_listboxes,
        };

        library_page.connect_signals();
        library_page
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
