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

use std::fs;
use std::fs::File;
use std::io;
use std::sync::mpsc::{channel, Receiver, Sender};

use app::Action;
use widgets::collection_listbox::CollectionListBox;
use widgets::station_row::ContentType;
use station_model::StationModel;

static SQL_READ: &str = "SELECT station_id, collection_name, library.collection_id FROM library LEFT JOIN collections ON library.collection_id = collections.collection_id ORDER BY library.collection_id ASC;";
static SQL_INIT_LIBRARY: &str = "CREATE TABLE \"library\" ('station_id' INTEGER, 'collection_id' INTEGER);";
static SQL_INIT_COLLECTIONS: &str = " CREATE TABLE \"collections\" ('collection_id' INTEGER, 'collection_name' TEXT)";

pub struct Library {
    pub widget: gtk::Box,
    collection_listbox: CollectionListBox,

    db_path: PathBuf,
    content: RefCell<HashMap<String, StationModel>>,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Library {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/library.ui");
        let widget: gtk::Box = builder.get_object("library").unwrap();
        let content_box: gtk::Box = builder.get_object("content_box").unwrap();
        let collection_listbox = CollectionListBox::new(sender.clone(), ContentType::Library);

        let db_path = Self::get_database_path().expect("Could not open database path...");
        let content = RefCell::new(HashMap::new());

        let library = Self {
            widget,
            collection_listbox,
            db_path,
            content,
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

        // read database and import data
        library.import_from_path(&library.db_path).expect("Could not import stations from database");

        library.setup_signals();
        library
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
                sender.send(Action::LibraryAddStations(name, stations.export_vec())).unwrap();
            }
        });

        Ok(())
    }

    pub fn add_stations(&self, collection_name: &str, stations: Vec<Station>) {
        Self::insert_into_hashmap(&mut self.content.borrow_mut(), collection_name, stations);
        self.refresh();
    }

    pub fn remove_stations(&self, stations: Vec<Station>) {
        Self::remove_from_hashmap(&mut self.content.borrow_mut(), stations);
        self.refresh();
    }

    pub fn write_data(&self){
        Self::write_stations_to_db(&self.db_path, &mut self.content.borrow_mut()).expect("Could not write stations to database.");
    }

    pub fn refresh(&self) {
        //self.collection_listbox.set_collections(&self.content.borrow());
    }

    fn read_stations_from_db(path: &PathBuf) -> Result<HashMap<String, StationModel>> {
        debug!("Read stations from \"{:?}\"", path);
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

    fn write_stations_to_db(path: &PathBuf, content: &mut HashMap<String, StationModel>) -> Result<()> {
        info!("Delete previous database data...");
        fs::remove_file(path).unwrap();
        Self::create_database(&path);

        info!("Write stations to \"{:?}\"", path);
        let connection = Connection::open(path.clone()).unwrap();

        // Insert data into database
        let mut collection_id = 1;
        for (collection_name, stations) in content{
            let mut coll_id = 0;
            if collection_name != "" {
                coll_id = collection_id;

                let mut stmt = connection.prepare(&format!("INSERT INTO collections VALUES ('{}', '{}');", coll_id.to_string(), collection_name))?;
                stmt.execute(&[]).unwrap();

                collection_id = collection_id +1;
            }

            for (id, station) in stations{
                let mut stmt = connection.prepare(&format!("INSERT INTO library VALUES ('{}', '{}');", id.to_string(), coll_id.to_string()))?;
                stmt.execute(&[]).unwrap();
            }
        }
        Ok(())
    }

    fn insert_into_hashmap(content: &mut HashMap<String, StationModel>, collection_name: &str, stations: Vec<Station>){
        if content.contains_key(collection_name) { // Collection already exists
            let station_model = content.get_mut(collection_name).unwrap();
            station_model.add_stations(stations);
        } else { // Insert as new collection
            let mut station_model = StationModel::new();
            station_model.add_stations(stations);
            content.insert(collection_name.to_string(), station_model);
        }
    }

    fn remove_from_hashmap(content: &mut HashMap<String, StationModel>, stations: Vec<Station>){
        for (collection_name, station_model) in content{
            station_model.remove_stations(stations.clone());
        }
    }

    fn get_database_path() -> io::Result<PathBuf> {
        let mut path = glib::get_user_data_dir().unwrap();

        if !path.exists() {
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio");
        if !path.exists() {
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio.db");
        if !path.exists() {
            Self::create_database(&path);
        }

        Ok(path)
    }

    fn create_database(path: &PathBuf) -> io::Result<()>{
        info!("Create new database...");
        File::create(&path.to_str().unwrap())?;

        info!("Initialize database...");
        let connection = Connection::open(path.clone()).unwrap();
        let mut stmt = connection.prepare(SQL_INIT_LIBRARY).expect("Could not initialize sqlite database");
        stmt.execute(&[]).unwrap();
        let mut stmt = connection.prepare(SQL_INIT_COLLECTIONS).expect("Could not initialize sqlite database");
        stmt.execute(&[]).unwrap();
        Ok(())
    }

    fn setup_signals(&self) {}
}
