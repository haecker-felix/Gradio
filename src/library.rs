extern crate glib;
extern crate rusqlite;

use rusqlite::Connection;
use rustio::{client::Client, station::Station};
use std::collections::HashMap;
use std::fs;
use std::fs::File;
use std::io;
use std::cell::RefCell;
use std::rc::Rc;

pub struct Library {
    connection: Connection,
    client: Client,

    update_callbacks: Rc<RefCell<Vec<Rc<RefCell<FnMut(Update)>>>>>,
}

#[derive(Clone)]
pub enum Update{
    // Station / Collection ID
    StationAdded(Station, i32),
    StationRemoved(Station, i32),

    CollectionAdded(i32, String),
    CollectionRemoved(i32),
}

impl Library {
    pub fn new() -> Self {
        let path = Self::get_library_path();
        let connection = match path {
            Ok(path) => Connection::open(path).unwrap(),
            Err(err) => {
                warn!("Cannot open database: {}", err);
                warn!("Gradio is using a temporary database!");
                Connection::open_in_memory().unwrap()
            }
        };
        let client = Client::new();
        let update_callbacks = Rc::new(RefCell::new(Vec::new()));

        Library { client, connection, update_callbacks }
    }

    pub fn read(&mut self) {
        // Check if database is initialized
        let mut stmt = self.connection.prepare("SELECT * FROM sqlite_master where type='table';").unwrap();
        let mut rows = stmt.query(&[]).unwrap();

        match rows.next() {
            Some(_) => (),
            None => {
                info!("Initialize database...");
                let library_table = "CREATE TABLE \"library\" ('station_id' INTEGER, 'collection_id' INTEGER);";
                self.connection.execute(library_table, &[]).expect("Could not initialize database");

                let collection_table = "CREATE TABLE \"collections\" ('collection_id' INTEGER, 'collection_name' TEXT);";
                self.connection.execute(collection_table, &[]).expect("Could not initialize database");
            }
        }

        // Read database itself
        info!("Read database...");
        debug!("{:?}", self.connection);
        let mut stmt = self.connection.prepare("SELECT * FROM library").unwrap();
        let mut rows = stmt.query(&[]).unwrap();

        while let Some(result_row) = rows.next() {
            let row = result_row.unwrap();
            let station_id: i32 = row.get(0);
            let collection_id: i32 = row.get(1);

            let station = self.client.get_station_by_id(station_id);
            let station = match station {
                Some(v) => v,
                None    => continue, 
            };
            info!("Found Station: {}", station.name);
            Self::update(&self.update_callbacks, Update::CollectionAdded(collection_id, self.get_collection_name(&collection_id)));
            Self::update(&self.update_callbacks, Update::StationAdded(station, collection_id));
        }
    }

    pub fn get_collection_name(&self, collection_id: &i32) -> String {
        let mut stmt = self.connection.prepare(&format!("SELECT collection_name FROM collections WHERE collection_id = {}", collection_id)).unwrap();
        let mut rows = stmt.query(&[]).unwrap();
        let mut name: String = "".to_string();

        while let Some(result_row) = rows.next() {
            let row = result_row.unwrap();
            name = row.get(0);
        }
        name
    }

    fn get_library_path() -> io::Result<String> {
        let mut path = glib::get_user_data_dir().unwrap();
        debug!("User data dir: {:?}", path);

        if !path.exists() {
            info!("Create new user data directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio");
        if !path.exists() {
            info!("Create new data directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio.db");
        if !path.exists() {
            info!("Create new database...");
            File::create(&path.to_str().unwrap())?;
        }

        return Ok(path.to_str().unwrap().to_string());
    }

    pub fn register_update_callback<F: FnMut(Update)+'static>(&mut self, callback: F) {
        let cell = Rc::new(RefCell::new(callback));
        self.update_callbacks.borrow_mut().push(cell);
    }

    fn update(update_callbacks: &Rc<RefCell<Vec<Rc<RefCell<FnMut(Update)>>>>>, val: Update) {
        for callback in update_callbacks.borrow_mut().iter() {
            let mut closure = callback.borrow_mut();
            (&mut *closure)(val.clone());
        }
    }
}
