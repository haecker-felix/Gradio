extern crate serde;
extern crate serde_json;
extern crate reqwest;
extern crate gtk;
use gtk::prelude::*;

use country::Country;
use station::Station;
use std::env;
use std::collections::HashMap;
use std::sync::mpsc::Sender;
use std::sync::mpsc::channel;
use std::thread;
use std::thread::JoinHandle;
use std::rc::Rc;
use std::cell::RefCell;

#[derive(Deserialize)]
pub struct StationUrlResult{
    pub url: String,
}

const BASE_URL: &'static str = "https://www.radio-browser.info/webservice/";

const LANGUAGES: &'static str = "json/languages/";
const COUNTRIES: &'static str = "json/countries/";
const STATES: &'static str = "json/states/";
const TAGS: &'static str = "json/tags/";

const PLAYABLE_STATION_URL: &'static str = "v2/json/url/";
const STATION_BY_ID: &'static str = "json/stations/byid/";
const SEARCH: &'static str ="json/stations/search";

pub enum ClientUpdate {
    NewStations(Vec<Station>),
    Clear,
}

pub struct Client {
    current_search_id: Rc<RefCell<u64>>,
}

impl Client {
    pub fn new() -> Client {
        Client {
            current_search_id: Rc::new(RefCell::new(0)),
        }
    }

    pub fn create_reqwest_client() -> reqwest::Client{
        let proxy: Option<String> = match env::var("http_proxy") {
            Ok(proxy) => Some(proxy),
            Err(_) => None,
        };

        match proxy {
            Some(proxy_address) => {
                info!("Use Proxy: {}", proxy_address);
                let proxy = reqwest::Proxy::all(&proxy_address).unwrap();
                reqwest::Client::builder().proxy(proxy).build().unwrap()
            },
            None => reqwest::Client::new(),
        }
    }

    pub fn get_all_languages(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, LANGUAGES);
        Self::send_get_request(url).unwrap().json().unwrap()
    }

    pub fn get_all_countries(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, LANGUAGES);
        Self::send_get_request(url).unwrap().json().unwrap()
    }

    pub fn get_all_states(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, STATES);
        Self::send_get_request(url).unwrap().json().unwrap()
    }

    pub fn get_all_tags(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, TAGS);
        Self::send_get_request(url).unwrap().json().unwrap()
    }

    pub fn get_station_by_id(&self, id: i32) -> Result<Station,&str> {
        let url = format!("{}{}{}", BASE_URL, STATION_BY_ID, id);
        let mut result : Vec<Station> = Self::send_get_request(url).unwrap().json().unwrap();

        if result.len() > 0 {
            Ok(result.remove(0))
        }else {
            Err("ID points to an empty station")
        }
    }

    pub fn get_playable_station_url(&self, station: &Station) -> JoinHandle<StationUrlResult> {
        let url = format!("{}{}{}", BASE_URL, PLAYABLE_STATION_URL, station.id);
        let result:JoinHandle<StationUrlResult>  = thread::spawn(move || {
            Self::send_get_request(url).unwrap().json().unwrap()
        });
        result
    }

    pub fn search(&mut self, params: HashMap<String, String>, sender: Sender<ClientUpdate>){
        // Generate a new search ID. It is possible, that the old thread is still running,
        // while a new one already have started. With this ID we can check, if the search request is still up-to-date.
        *self.current_search_id.borrow_mut() += 1;
        debug!("Start new search with ID {}", self.current_search_id.borrow());
        sender.send(ClientUpdate::Clear);

        // Do the actual search in a new thread
        let (search_sender, search_receiver) = channel();
        let url = format!("{}{}", BASE_URL, SEARCH);
        thread::spawn(move || search_sender.send(Self::send_post_request(url, params).unwrap().json().unwrap())); //TODO: don't unwrap

        // Start a loop, and wait for a message from the thread.
        let current_search_id = self.current_search_id.clone();
        let search_id = *self.current_search_id.borrow();
        let sender = sender.clone();
        gtk::timeout_add(100,  move|| {
            if search_id != *current_search_id.borrow() { // Compare with current search id
                debug!("Search ID changed -> cancel this search loop. (This: {} <-> Current: {})", search_id, current_search_id.borrow());
                return Continue(false);
            }

            match search_receiver.try_recv(){
                Ok(stations) => {
                    sender.send(ClientUpdate::NewStations(stations));
                    Continue(false)
                }
                Err(_) => Continue(true),
            }
        });
    }

    fn send_post_request(url: String, params: HashMap<String, String>) -> Result<reqwest::Response, reqwest::Error>{
        debug!("Post request -> {:?} ({:?})", url, params);
        let client = Self::create_reqwest_client();
        client.post(&url).form(&params).send()
    }

    fn send_get_request(url: String) -> Result<reqwest::Response, reqwest::Error>{
        debug!("Get request -> {:?}", url);
        let client = Self::create_reqwest_client();
        client.get(&url).send()
    }
}
