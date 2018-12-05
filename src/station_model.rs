use indexmap::IndexMap;
use indexmap::map::Entry;
use rustio::Station;

#[derive(Clone, Debug)]
pub enum Sorting{
    Name,
    Language,
    Country,
    State,
    Codec,
    Votes,
    Bitrate,
}

#[derive(Clone, Debug)]
pub enum Order{
    Ascending,
    Descending,
}


#[derive(Clone, Debug)]
pub struct StationModel{
    map: IndexMap<u32, Station>,
    sorting: Sorting,
    order: Order,
}

impl StationModel{
    pub fn new() -> Self{
        let map: IndexMap<u32, Station> = IndexMap::new();

        let sorting = Sorting::Name;
        let order = Order::Ascending;

        Self { map, sorting, order }
    }

    pub fn export_vec (&self) -> Vec<Station> {
        let mut result = Vec::new();
        for (_id, station) in self.map.clone() {
            result.insert(0, station);
        }
        result
    }

    pub fn add_station(&mut self, station: Station) -> Option<usize>{
        let mut index = None;
        if !self.contains(&station) {
            let id = station.id.parse::<u32>().unwrap();
            self.map.insert(id.clone(), station);
            self.sort();
            index = match self.map.entry(id){
                Entry::Occupied(e) => Some(e.index()),
                _ => None,
            };
        }
        index
    }

    pub fn remove_station(&mut self, station: Station) -> Option<usize>{
        let mut index = None;
        if self.contains(&station) {
            let id = station.id.parse::<u32>().unwrap();
            index = Some(self.map.swap_remove_full(&id).unwrap().0);
            self.sort();
        }
        index
    }

    pub fn contains(&self, station: &Station) -> bool{
        let id = station.id.parse::<u32>().unwrap();
        self.map.contains_key(&id)
    }

    pub fn set_sorting(&mut self, sorting: Sorting, order: Order){
        self.sorting = sorting;
        self.order = order;
    }

    pub fn sort(&mut self){
        let order = self.order.clone();
        let sorting = self.sorting.clone();

        self.map.sort_by(move|_, b, _, d|{
            let station_a: Station;
            let station_b: Station;

            match order{
                Order::Ascending => {
                    station_a = b.clone();
                    station_b = d.clone();
                },
                Order::Descending => {
                    station_b = b.clone();
                    station_a = d.clone();
                },
            }

            match sorting{
                Sorting::Name => station_a.name.cmp(&station_b.name),
                Sorting::Language => station_a.language.cmp(&station_b.language),
                Sorting::Country => station_a.country.cmp(&station_b.country),
                Sorting::State => station_a.state.cmp(&station_b.state),
                Sorting::Codec => station_a.codec.cmp(&station_b.codec),
                Sorting::Votes => station_a.votes.parse::<i32>().unwrap().cmp(&station_b.votes.parse::<i32>().unwrap()),
                Sorting::Bitrate => station_a.bitrate.parse::<i32>().unwrap().cmp(&station_b.bitrate.parse::<i32>().unwrap()),
            }
        });
    }
}

impl IntoIterator for StationModel {
    type Item = (u32, Station);
    type IntoIter = ::indexmap::map::IntoIter<u32, Station>;

    fn into_iter(self) -> Self::IntoIter {
        self.map.into_iter()
    }
}
