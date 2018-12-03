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

use app::{Action,AppInfo};
use widgets::station_row::ContentType;
use widgets::station_listbox::StationListBox;
use station_model::StationModel;

static SQL_READ: &str = "SELECT station_id, collection_name, library.collection_id FROM library LEFT JOIN collections ON library.collection_id = collections.collection_id ORDER BY library.collection_id ASC;";
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

        let db_path = Self::get_database_path().expect("Could not open database path...");

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

        // Setup HdyColumn
        let column = Column::new();
        column.set_maximum_width(700);
        content_box.add(&column);
        let column = column.upcast::<gtk::Widget>(); // See https://gitlab.gnome.org/World/podcasts/blob/master/podcasts-gtk/src/widgets/home_view.rs#L64
        let column = column.downcast::<gtk::Container>().unwrap();
        column.show();
        column.add(&library.station_listbox.borrow().widget);

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

    pub fn write_data(&self){
        Self::write_stations_to_db(&self.db_path, self.station_listbox.borrow().get_stations()).expect("Could not write stations to database.");
    }

    pub fn import_from_path(&self, path: &PathBuf) -> Result<()>{
        // test sql connection
        let connection = Connection::open(path.clone()).unwrap();
        let mut stmt = connection.prepare(SQL_READ)?;

        let sender = self.sender.clone();
        let p = path.clone();
        self.set_visible_page("loading");
        thread::spawn(move|| {
            let stations = Self::read_stations_from_db(&p).unwrap();
            sender.send(Action::LibraryAddStations(stations)).unwrap();
        });

        Ok(())
    }

    fn read_stations_from_db(path: &PathBuf) -> Result<Vec<Station>> {
        debug!("Read stations from \"{:?}\"", path);
        let mut result = Vec::new();
        let mut client = Client::new("http://www.radio-browser.info");
        let connection = Connection::open(path.clone()).unwrap();
        let mut stmt = connection.prepare(SQL_READ)?;
        let mut rows = stmt.query(&[]).unwrap();

        while let Some(result_row) = rows.next() {
            let row = result_row.unwrap();
            let station_id: u32 = row.get(0);

            client.get_station_by_id(station_id).map(|station| {
                info!("Found Station: {}", station.name);
                result.insert(0, station);
            });
        }
        Ok(result)
    }

    fn write_stations_to_db(path: &PathBuf, stations: Vec<Station>) -> Result<()> {
        info!("Delete previous database data...");
        fs::remove_file(path).unwrap();
        Self::create_database(&path);

        info!("Write stations to \"{:?}\"", path);
        let connection = Connection::open(path.clone()).unwrap();
        for station in stations{
            let mut stmt = connection.prepare(&format!("INSERT INTO library VALUES ('{}', '0');", station.id.to_string(), ))?;
            stmt.execute(&[]).unwrap();
        }

        Ok(())
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

    fn update_visible_page(&self){
        if(self.station_listbox.borrow().get_stations().len() != 0){
            self.set_visible_page("content");
        }else{
            self.set_visible_page("empty");
        }
    }

    fn set_visible_page(&self, name: &str){
        let stack: gtk::Stack = self.builder.get_object("library_stack").unwrap();
        stack.set_visible_child_name(name);
    }

    fn setup_signals(&self) {}
}
