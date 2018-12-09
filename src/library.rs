use gtk::prelude::*;
use rusqlite::Connection;
use rustio::{Client, Station};

use std::cell::RefCell;
use std::fs;
use std::fs::File;
use std::io;
use std::path::PathBuf;
use std::result::Result;
use std::sync::mpsc::Sender;
use std::thread;

use crate::app::{Action, AppInfo};
use crate::station_model::{Order, Sorting};
use crate::widgets::station_listbox::StationListBox;
use crate::widgets::station_row::ContentType;

static SQL_READ: &str = "SELECT station_id, collection_name, library.collection_id
                        FROM library LEFT JOIN collections ON library.collection_id = collections.collection_id ORDER BY library.collection_id ASC;";
static SQL_INIT_LIBRARY: &str = "CREATE TABLE \"library\" ('station_id' INTEGER, 'collection_id' INTEGER);";
static SQL_INIT_COLLECTIONS: &str = " CREATE TABLE \"collections\" ('collection_id' INTEGER, 'collection_name' TEXT)";

pub struct Library {
    pub widget: gtk::Box,
    station_listbox: RefCell<StationListBox>,

    db_path: PathBuf,
    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Library {
    pub fn new(sender: Sender<Action>, info: &AppInfo) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/library.ui");
        let widget: gtk::Box = builder.get_object("library").unwrap();
        let content_box: gtk::Box = builder.get_object("content_box").unwrap();
        let station_listbox = RefCell::new(StationListBox::new(sender.clone(), ContentType::Library));
        content_box.add(&station_listbox.borrow().widget);

        let db_path = Self::get_database_path("gradio.db").expect("Could not open database path...");

        let logo_image: gtk::Image = builder.get_object("logo_image").unwrap();
        logo_image.set_from_icon_name(Some(format!("{}-symbolic", info.app_id).as_str()), 128);
        let welcome_text: gtk::Label = builder.get_object("welcome_text").unwrap();
        welcome_text.set_text(format!("Welcome to {}", info.app_name).as_str());

        let library = Self {
            widget,
            station_listbox,
            db_path,
            builder,
            sender,
        };

        // read database and import data
        library.import_from_path(&library.db_path).expect("Could not import stations from database");

        library.setup_signals();
        library
    }

    pub fn add_stations(&self, stations: Vec<Station>) {
        self.station_listbox.borrow_mut().add_stations(stations);
        self.update_visible_page();
    }

    pub fn remove_stations(&self, stations: Vec<Station>) {
        self.station_listbox.borrow_mut().remove_stations(stations);
        self.update_visible_page();
    }

    pub fn write_data(&self) {
        Self::write_stations_to_db(&self.db_path, self.station_listbox.borrow().get_stations()).expect("Could not write stations to database.");
    }

    pub fn import_from_path(&self, path: &PathBuf) -> Result<(), LibraryError> {
        // test sql connection
        let connection = Connection::open(path.clone())?;
        let mut _stmt = connection.prepare(SQL_READ)?;

        let sender = self.sender.clone();
        let p = path.clone();
        self.set_visible_page("loading");
        thread::spawn(move || {
            match Self::read_stations_from_db(&p) {
                Ok(stations) => sender.send(Action::LibraryAddStations(stations)).unwrap(),
                Err(err) => {
                    sender.send(Action::LibraryAddStations(Vec::new())).unwrap();
                    sender.send(Action::ViewShowNotification(format!("Could not load stations - {}", err.to_string()).to_string())).unwrap();
                }
            };
        });

        Ok(())
    }

    pub fn export_to_path(&self, path: &PathBuf) -> Result<(), LibraryError> {
        Self::write_stations_to_db(&path, self.station_listbox.borrow().get_stations()).expect("Could not export database.");
        Ok(())
    }

    pub fn set_sorting(&self, sorting: Sorting, order: Order) {
        self.station_listbox.borrow_mut().set_sorting(sorting, order);
    }

    fn read_stations_from_db(path: &PathBuf) -> Result<Vec<Station>, LibraryError> {
        debug!("Read stations from \"{:?}\"", path);
        let mut result = Vec::new();
        let mut client = Client::new("http://www.radio-browser.info");
        let connection = Connection::open(path.clone())?;
        let mut stmt = connection.prepare(SQL_READ)?;
        let mut rows = stmt.query(&[])?;

        while let Some(result_row) = rows.next() {
            let row = result_row.unwrap();
            let station_id: u32 = row.get(0);

            client.get_station_by_id(station_id).map(|station| {
                info!("Found Station: {}", station.name);
                result.insert(0, station);
            })?;
        }
        Ok(result)
    }

    fn write_stations_to_db(path: &PathBuf, stations: Vec<Station>) -> Result<(), LibraryError> {
        if stations.len() == 0 {
            debug!("No stations - Do nothing.");
            return Ok(());
        }

        let tmpdb = Self::get_database_path("tmp.db")?;

        info!("Delete previous database data...");
        let _ = fs::remove_file(path);
        let _ = fs::remove_file(&tmpdb);
        let _ = Self::create_database(&tmpdb);

        info!("Write stations to \"{:?}\"", tmpdb);
        let connection = Connection::open(tmpdb.clone())?;
        for station in stations {
            let mut stmt = connection.prepare(&format!("INSERT INTO library VALUES ('{}', '0');", station.id.to_string(),))?;
            stmt.execute(&[])?;
        }

        debug!("Move tmp.db to real path...");
        let _ = fs::copy(&tmpdb, &path);

        Ok(())
    }

    fn get_database_path(name: &str) -> Result<PathBuf, LibraryError> {
        let mut path = glib::get_user_data_dir().unwrap();

        if !path.exists() {
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio");
        if !path.exists() {
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push(name);
        if !path.exists() {
            Self::create_database(&path)?;
        }

        Ok(path)
    }

    fn create_database(path: &PathBuf) -> Result<(), LibraryError> {
        info!("Create new database...");
        File::create(&path.to_str().unwrap())?;

        info!("Initialize database...");
        let connection = Connection::open(path.clone())?;
        let mut stmt = connection.prepare(SQL_INIT_LIBRARY).expect("Could not initialize sqlite database");
        stmt.execute(&[])?;
        let mut stmt = connection.prepare(SQL_INIT_COLLECTIONS).expect("Could not initialize sqlite database");
        stmt.execute(&[])?;
        Ok(())
    }

    fn update_visible_page(&self) {
        if self.station_listbox.borrow().get_stations().len() != 0 {
            self.set_visible_page("content");
        } else {
            self.set_visible_page("empty");
        }
    }

    fn set_visible_page(&self, name: &str) {
        let stack: gtk::Stack = self.builder.get_object("library_stack").unwrap();
        stack.set_visible_child_name(name);
    }

    fn setup_signals(&self) {}
}

quick_error! {
    #[derive(Debug)]
    pub enum LibraryError {
        Io(err: io::Error) {
            from()
            description("io error")
            display("I/O error: {}", err)
            cause(err)
        }
        Sqlite(err: rusqlite::Error) {
            from()
            description("sqlite error")
            display("Database error: {}", err)
            cause(err)
        }
        Restson(err: restson::Error) {
            from()
            description("restson error")
            display("Network error: {}", err)
            cause(err)
        }
    }
}
