extern crate glib;
extern crate rusqlite;

use rusqlite::Connection;
use rustio::{Client, Station};
use std::collections::HashMap;

use mdl::model::Model;

#[derive(Serialize, Deserialize, Debug)]
pub struct Library {
    pub stations: HashMap<Station, Option<String>> // station, collection name
}

impl Model for Library {
    fn key(&self) -> String { "library".to_string() }
}

impl Library {
    pub fn new() -> Self {
        let mut stations = HashMap::new();
        let mut library = Library { stations };

        Self::get_old_db_path().map(|path| library.import_db(path));

        library
    }

    pub fn contains(&self, station: &Station) -> bool {
        self.stations.contains_key(&station)
    }

    pub fn add_station(&mut self, station: Station, collection_name: Option<String>){
        info!("Add station to library: {} ({})", station.name, station.id);
        self.stations.insert(station, collection_name);
    }

    pub fn remove_station(&mut self, station: &Station){
        info!("Remove station from library: {} ({})", station.name, station.id);
        self.stations.remove(&station);
    }

    fn get_old_db_path() -> Option<String>{
        let mut path = glib::get_user_data_dir().unwrap();
        path.push("gradio");
        path.push("gradio.db");

        info!("Check for old database format at {:?}", path);
        if path.exists(){
            return Some(path.to_str().unwrap().to_string());
        }
        None
    }

    fn import_db(&mut self, path: String){
        let client = Client::new("http://www.radio-browser.info".to_string());
        let connection = Connection::open(path).unwrap();

        // Read database itself
        info!("Import database from...");
        debug!("{:?}", connection);
        let mut stmt = connection.prepare("SELECT * FROM library").unwrap();
        let mut rows = stmt.query(&[]).unwrap();

        while let Some(result_row) = rows.next() {
            let row = result_row.unwrap();
            let station_id: i32 = row.get(0);
            let collection_id: i32 = row.get(1);

            client.get_station_by_id(station_id).map(|station|{
                info!("Found Station: {}", station.name);
                self.stations.insert(station, Some(collection_id.to_string()));
            });
        }
    }
}
