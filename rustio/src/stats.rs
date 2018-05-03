#[derive(Deserialize)]
pub struct Stats {
    pub stations: String,
    pub stations_broken: String,
    pub tags: String,
    pub clicks_last_hour: String,
    pub clicks_last_day: String,
    pub languages: String,
    pub countries: String,
}

impl Stats{
    pub fn print(&self){
        println!("Stations: {} ({} broken)\nTags: {}\n\
            Languages: {}\n\
            Countries: {}\n\
            Clicks: {} last hour / {} last day",
                 self.stations,
                 self.stations_broken,
                 self.tags,
                 self.languages,
                 self.countries,
                 self.clicks_last_hour,
                 self.clicks_last_day);
    }
}