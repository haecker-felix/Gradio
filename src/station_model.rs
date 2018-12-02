use indexmap::IndexMap;
use indexmap::map::OccupiedEntry;
use indexmap::map::Entry;
use rustio::Station;
use std::rc::Rc;
use std::cell::RefCell;
use std::cmp::Ordering;

#[derive(Clone, Debug)]
pub struct StationModel{
    map: IndexMap<u32, Station>,
}

impl StationModel{
    pub fn new() -> Self{
        let mut map: IndexMap<u32, Station> = IndexMap::new();
        Self { map }
    }

    pub fn export_vec (&self) -> Vec<Station> {
        let mut result = Vec::new();
        for (id, station) in self.map.clone() {
            result.insert(0, station);
        }
        result
    }

    pub fn add_station(&mut self, station: Station) -> Option<usize>{
        let mut index = None;
        if(!self.contains(&station)){
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
        if(self.contains(&station)){
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

    pub fn clear(&mut self){
        self.map.clear();
    }

    pub fn sort(&mut self){
        self.map.sort_by(|a_id, a_station, b_id, b_station|{
            a_station.name.cmp(&b_station.name)
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
