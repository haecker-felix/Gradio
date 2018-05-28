extern crate serde;
extern crate serde_json;
extern crate reqwest;
extern crate gtk;
extern crate rand;
use gtk::prelude::*;

use country::Country;
use station::Station;
use std::env;
use std::collections::HashMap;
use std::sync::mpsc::Sender;
use std::sync::mpsc::channel;
use std::thread;
use std::rc::Rc;
use rand::*;
use std::cell::RefCell;
use std::sync::atomic::AtomicUsize;

#[derive(Deserialize)]
pub struct StationUrlResult{
    ok: String,
    url: String,
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
    client_sender: Sender<ClientUpdate>,
    current_search_id: AtomicUsize,
}

impl Client {
    pub fn new() -> Client {
        let (sender, receiver) = channel();
        Self::new_with_sender(sender)
    }

    pub fn new_with_sender(client_sender: Sender<ClientUpdate>) -> Client {
        let mut current_search_id = AtomicUsize::new(0);
        Client {
            client_sender,
            current_search_id,
        }
    }

    pub fn create_reqwest_client() -> reqwest::Client{
        let proxy: Option<String> = match env::var("http_proxy") {
            Ok(proxy) => Some(proxy),
            Err(error) => None,
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

    pub fn get_station_by_id(&self, id: i32) -> Station{
        let url = format!("{}{}{}", BASE_URL, STATION_BY_ID, id);
        let mut result: Vec<Station> = Self::send_get_request(url).unwrap().json().unwrap();
        result.remove(0)
    }

    pub fn get_playable_station_url(&self, station: &Station) -> String{
        let url = format!("{}{}{}", BASE_URL, PLAYABLE_STATION_URL, station.id);
        let mut result: StationUrlResult = Self::send_get_request(url).unwrap().json().unwrap();
        result.url
    }

    pub fn search(&mut self, params: HashMap<String, String>){
        // Generate a new search ID. It is possible, that the old thread is still running,
        // while a new one already have started. With this ID we can check, if the search request is still up-to-date.
        *self.current_search_id.get_mut() = rand::random();
        debug!("Start new search with ID {}", self.current_search_id.into_inner());
        self.client_sender.send(ClientUpdate::Clear);

        // Do the actual search in a new thread
        let (search_sender, search_receiver) = channel();
        let url = format!("{}{}", BASE_URL, SEARCH);
        thread::spawn(move || search_sender.send(Self::send_post_request(url, params).unwrap().json().unwrap())); //TODO: don't unwrap

        // Start a loop, and wait for a message from the thread.
        let search_id: usize = self.current_search_id.into_inner();
        //let current_search_id = self.current_search_id.copy();
        let client_sender = self.client_sender.clone();
        gtk::timeout_add(100,  move|| {
            //debug!("timeout search_id: {}", search_id);
            //debug!(" - current_search_id: {}", current_search_id.borrow());
            if search_id != *current_search_id.borrow() { // Compare with current search id
                error!("Search ID changed -> cancel this loop. (This: {} <-> Current: {})", search_id, current_search_id.borrow());
                return Continue(false);
            }

            match search_receiver.try_recv(){
                Ok(mut stations) => {
                    client_sender.send(ClientUpdate::NewStations(stations));
                    Continue(false)
                }
                Err(err) => Continue(true),
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