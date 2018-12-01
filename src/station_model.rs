use indexmap::IndexMap;
use rustio::Station;
use std::rc::Rc;
use std::cell::RefCell;

pub struct StationModel{
    map: IndexMap<u32, Station>,

    add_cb: Vec<Rc<RefCell<FnMut()>>>,
    remove_cb: Vec<Rc<RefCell<FnMut()>>>,
    clear_cb: Vec<Rc<RefCell<FnMut()>>>,
}

impl StationModel{
    pub fn new() -> Self{
        let mut map = IndexMap::new();

        Self {
            map,
            add_cb: Vec::new(),
            remove_cb: Vec::new(),
            clear_cb: Vec::new(),
        }
    }

    pub fn export_vec (&self) -> Vec<Station> {
        let mut result = Vec::new();
        for (id, station) in self.map.clone() {
            result.insert(0, station);
        }
        result
    }

    pub fn add_stations(&mut self, stations: Vec<Station>){
        for station in stations{
            let id = station.id.parse::<u32>().unwrap();
            self.map.insert(id, station);
        }

        // callback
        for callback in self.add_cb.iter() {
            let mut closure = callback.borrow_mut(); (&mut *closure)();
        }
    }

    pub fn remove_stations(&mut self, stations: Vec<Station>){
        for station in stations{
            let id = station.id.parse::<u32>().unwrap();
            self.map.remove(&id);
        }

        // callback
        for callback in self.remove_cb.iter() {
            let mut closure = callback.borrow_mut(); (&mut *closure)();
        }
    }

    pub fn clear(&mut self){
        self.map.clear();

        // callback
        for callback in self.clear_cb.iter() {
            let mut closure = callback.borrow_mut(); (&mut *closure)();
        }
    }

    pub fn connect_add<F: FnMut()+'static>(&mut self, callback: F) {
        let cell = Rc::new(RefCell::new(callback));
        self.add_cb.push(cell);
    }

    pub fn connect_remove<F: FnMut()+'static>(&mut self, callback: F) {
        let cell = Rc::new(RefCell::new(callback));
        self.remove_cb.push(cell);
    }

    pub fn connect_clear<F: FnMut()+'static>(&mut self, callback: F) {
        let cell = Rc::new(RefCell::new(callback));
        self.clear_cb.push(cell);
    }
}

impl Iterator for StationModel {
    type Item = (u32, Station);

    fn next(&mut self) -> Option<(u32, Station)> {
        match self.map.clone().into_iter().next() {
            Some(r) => Some(r),
            None => None,
        }
    }
}
