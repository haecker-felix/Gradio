extern crate serde;
extern crate serde_json;
extern crate reqwest;

use country::Country;
use station::Station;
use std::env;

#[derive(Deserialize)]
pub struct StationUrlResult{
    ok: String,
    url: String,
}

const BASE_URL: &'static str = "http://www.radio-browser.info/webservice/";

const LANGUAGES: &'static str = "json/languages/";
const COUNTRIES: &'static str = "json/countries/";
const STATES: &'static str = "json/states/";
const TAGS: &'static str = "json/tags/";

const PLAYABLE_STATION_URL: &'static str = "v2/json/url/";
const STATION_BY_ID: &'static str = "json/stations/byid/";
const SEARCH: &'static str ="json/stations/search/";

pub struct Client {
    client: reqwest::Client,
}

impl Client {
    pub fn new() -> Client {

        let proxy: Option<String> = match env::var("http_proxy") {
            Ok(proxy) => Some(proxy),
            Err(error) => None,
        };

        let client = match proxy {
            Some(proxy_address) => {
                info!("Use Proxy: {}", proxy_address);
                let proxy = reqwest::Proxy::http(&proxy_address).unwrap();
                reqwest::Client::builder().proxy(proxy).build().unwrap()
            },
            None => reqwest::Client::new(),
        };

        Client {
            client: client,
        }
    }

    pub fn get_all_languages(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, LANGUAGES);
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_all_countries(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, LANGUAGES);
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_all_states(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, STATES);
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_all_tags(&self) -> Vec<Country>{
        let url = format!("{}{}", BASE_URL, TAGS);
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_station_by_id(&self, id: i32) -> Station{
        let url = format!("{}{}{}", BASE_URL, STATION_BY_ID, id);
        let mut result: Vec<Station> = self.client.get(&url).send().unwrap().json().unwrap();
        result.remove(0)
    }

    pub fn get_playable_station_url(&self, station: &Station) -> String{
        let url = format!("{}{}{}", BASE_URL, PLAYABLE_STATION_URL, station.id);
        let mut result: StationUrlResult = self.client.get(&url).send().unwrap().json().unwrap();
        result.url
    }

    pub fn search(&self, params: [(&str, &str); 2]) -> Vec<Station>{
        let url = format!("{}{}", BASE_URL, SEARCH);
        self.client.post(&url).form(&params).send().unwrap().json().unwrap()
    }
}