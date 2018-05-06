extern crate glib;
extern crate rusqlite;
use rusqlite::{Connection, OpenFlags};

use std::io;
use std::fs::File;
use std::fs;
use std::rc::Rc;
use std::collections::HashMap;
use rustio::{client::Client, station::Station};

pub struct Library{
    pub stations: HashMap<i32, Station>,
    connection: Connection,
}

impl Library{
    pub fn new() -> Self{
        let mut stations: HashMap<i32, Station> = HashMap::new();

        let path = Self::get_library_path();
        let connection = match path{
            Ok(path) => Connection::open(path).unwrap(),
            Err(err) => {
                warn!("Cannot open database: {}", err);
                warn!("Gradio is using a temporary database!");
                Connection::open_in_memory().unwrap()
            }
        };

        Library{stations, connection}
    }

    pub fn read(&mut self, client: &Rc<Client>){
        // Check if database is initialized
        let mut stmt = self.connection.prepare("SELECT * FROM sqlite_master where type='table';").unwrap();
        let mut rows = stmt.query(&[]).unwrap();

        match rows.next() {
            Some(row) => (),
            None => {
                info!("Initialize database...");
                let sql = "CREATE TABLE \"library\" ('station_id' INTEGER, 'collection_id' INTEGER); CREATE TABLE \"collections\" ('collection_id' INTEGER, 'collection_name' TEXT)";
                self.connection.execute(sql, &[]).expect("Could not initialize database");
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

            let station = client.get_station_by_id(station_id);
            info!("Found Station: {}", station.name);
            self.stations.insert(station_id, station);
        }
    }

    fn get_library_path() -> io::Result<String> {
        let mut path = glib::get_user_data_dir().unwrap();

        path.push("gradio");
        if !path.exists() {
            info!("Create new data directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio.db");
        if(!path.exists()){
            info!("Create new database...");
            File::create(&path.to_str().unwrap())?;
        }

        return Ok(path.to_str().unwrap().to_string());
    }
}