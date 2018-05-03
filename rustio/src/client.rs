extern crate serde;
extern crate serde_json;
extern crate reqwest;

use country::Country;
use station::Station;

#[derive(Deserialize)]
pub struct StationUrlResult{
    ok: String,
    url: String,
}

pub struct Client {
    client: reqwest::Client,
    server_url: String,
}

impl Client {
    pub fn new() -> Client {
        let client = reqwest::Client::new();
        Client {
            client: client,
            server_url: "http://www.radio-browser.info/webservice/".to_string(),
        }
    }

    pub fn get_all_languages(&self) -> Vec<Country>{
        let url: String = format!("{}{}", self.server_url, "json/languages/");
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_all_countries(&self) -> Vec<Country>{
        let url: String = format!("{}{}", self.server_url, "json/countries/");
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_all_states(&self) -> Vec<Country>{
        let url: String = format!("{}{}", self.server_url, "json/states/");
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_all_tags(&self) -> Vec<Country>{
        let url: String = format!("{}{}", self.server_url, "json/tags/");
        self.client.get(&url).send().unwrap().json().unwrap()
    }

    pub fn get_station_by_id(&self, id: i32) -> Station{
        let url: String = format!("{}{}{}", self.server_url, "json/stations/byid/", id);
        let mut result: Vec<Station> = self.client.get(&url).send().unwrap().json().unwrap();
        result.remove(0)
    }

    pub fn get_playable_station_url(&self, station: &Station) -> String{
        let url: String = format!("{}{}{}", self.server_url, "v2/json/url/", station.id);
        let mut result: StationUrlResult = self.client.get(&url).send().unwrap().json().unwrap();
        result.url
    }
}