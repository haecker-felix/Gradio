extern crate gtk;
extern crate rusqlite;

use gtk::prelude::*;
use libhandy::{Column, ColumnExt};
use rusqlite::{Connection, Result, Statement};

use rustio::{Client, Station};
use std::cell::RefCell;
use std::collections::HashMap;
use std::path::PathBuf;
use std::thread;
use std::sync::mpsc::{channel, Receiver, Sender};

use app::Action;
use widgets::collection_listbox::CollectionListBox;

static SQL_READ: &str = "SELECT station_id, collection_name, library.collection_id FROM library LEFT JOIN collections ON library.collection_id = collections.collection_id ORDER BY library.collection_id;";


pub struct Library {
    pub widget: gtk::Box,
    content: RefCell<HashMap<String, Vec<Station>>>,
    collection_listbox: CollectionListBox,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Library {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/library.ui");
        let widget: gtk::Box = builder.get_object("library").unwrap();
        let content_box: gtk::Box = builder.get_object("content_box").unwrap();

        let content = RefCell::new(HashMap::new());
        let collection_listbox = CollectionListBox::new(sender.clone());

        let library = Self {
            widget,
            content,
            collection_listbox,
            builder,
            sender,
        };

        // Setup HdyColumn
        let column = Column::new();
        column.set_maximum_width(700);
        content_box.add(&column);
        let column = column.upcast::<gtk::Widget>(); // See https://gitlab.gnome.org/World/podcasts/blob/master/podcasts-gtk/src/widgets/home_view.rs#L64
        let column = column.downcast::<gtk::Container>().unwrap();
        column.show();
        column.add(&library.collection_listbox.widget);

        // check for old Gradio databases and import them automatically
        let mut path = glib::get_user_data_dir().unwrap();
        path.push("gradio");
        path.push("gradio.db");
        info!("Check for old database format at {:?}", path);
        if path.exists(){
            library.import_from_path(&path);
        }

        library.setup_signals();
        library
    }

    pub fn add_stations(&self, collection_name: &str, stations: Vec<Station>) {
        Self::insert_into_hashmap(&mut self.content.borrow_mut(), collection_name, stations);
        self.refresh();
    }

    pub fn import_from_path(&self, path: &PathBuf) -> Result<()>{
        // test sql connection
        let connection = Connection::open(path.clone()).unwrap();
        let mut stmt = connection.prepare(SQL_READ)?;

        let sender = self.sender.clone();
        let p = path.clone();
        thread::spawn(move|| {
            let result = Self::read_stations_from_db(&p).unwrap();
            for (name, stations) in result{
                sender.send(Action::LibraryAddStations(name, stations)).unwrap();
            }
        });

        Ok(())
    }

    fn read_stations_from_db(path: &PathBuf) -> Result<HashMap<String, Vec<Station>>> {
        let mut result = HashMap::new();
        let mut client = Client::new("http://www.radio-browser.info");
        let connection = Connection::open(path.clone()).unwrap();
        let mut stmt = connection.prepare(SQL_READ)?;
        let mut rows = stmt.query(&[]).unwrap();

        while let Some(result_row) = rows.next() {
            let row = result_row.unwrap();
            let station_id: u32 = row.get(0);
            let mut collection_name: String = "".to_string();
            let collection_id: u32 = row.get(2);

            if collection_id != 0{
                collection_name = row.get(1);
            }

            client.get_station_by_id(station_id).map(|station| {
                info!("Found Station: {}", station.name);
                Self::insert_into_hashmap(&mut result, &collection_name, vec![station]);
            });
        }
        Ok(result)
    }

    fn insert_into_hashmap(content: &mut HashMap<String, Vec<Station>>, collection_name: &str, stations: Vec<Station>){
        if content.contains_key(collection_name) { // Collection already exists
            let mut s = stations;
            let collection = content.get_mut(collection_name).unwrap().append(&mut s);
        } else { // Insert as new collection
            content.insert(collection_name.to_string(), stations.to_vec());
        }
    }

    pub fn refresh(&self) {
        self.collection_listbox.set_collections(&self.content.borrow());
    }

    fn setup_signals(&self) {}
}
