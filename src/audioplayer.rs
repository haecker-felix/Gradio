extern crate gstreamer;
extern crate gtk;
extern crate glib;
use glib::prelude::*;
use gstreamer::{Element, ElementFactory, ElementExt, Bus, Message, Continue, MessageView};
use gstreamer::prelude::*;
use rustio::station::Station;
use std::rc::Rc;
use std::cell::RefCell;
use std::sync::mpsc::{channel, Sender, Receiver};
use rustio::client::Client;
use std::thread;
use std::sync::Mutex;

pub struct AudioPlayer{
    playbin: Element,
    client: Client,
    station: Option<Station>,

    update_callbacks: Rc<RefCell<Vec<Rc<RefCell<FnMut(Update)>>>>>,
}

#[derive(Clone)]
pub enum State{
    Playing,
    Stopped,
    Loading,
}

#[derive(Clone)]
pub enum Update{
    Playback(State),
    Station(Station),
    Title(String),
}

impl AudioPlayer{
    pub fn new() -> AudioPlayer{
        gstreamer::init();

        let playbin = ElementFactory::make("playbin", "playbin").unwrap();
        let bus = playbin.get_bus().expect("Unable to get playbin bus");
        let client = Client::new();
        let station = None;
        let update_callbacks = Rc::new(RefCell::new(Vec::new()));

        Self::new_bus_messages(update_callbacks.clone(), bus);

        AudioPlayer{
            playbin,
            client,
            station,
            update_callbacks,
        }
    }

    pub fn set_playback(&mut self, play: bool){
        if play {
            debug!("Start playback...");
            self.playbin.set_state(gstreamer::State::Playing);
        }else{
            debug!("Stop playback...");
            self.playbin.set_state(gstreamer::State::Ready);
        };
    }

    pub fn set_station(&mut self, station: Station){
        Self::update(&self.update_callbacks, Update::Station(station.clone()));
        Self::update(&self.update_callbacks, Update::Title("".to_string()));
        self.playbin.set_state(gstreamer::State::Null);
        self.station = Some(station);
        
        //request url and set it in a new thread
        let playbin = Mutex::new(self.playbin.clone());
        let client = self.client.clone();
        let station = self.station.clone().unwrap(); 
        thread::spawn( move || {
            let station_url = client.get_playable_station_url(&station);      
            playbin.lock().unwrap().set_property("uri", &station_url);  
            playbin.lock().unwrap().set_state(gstreamer::State::Playing);
        }); 
    }

    pub fn register_update_callback<F: FnMut(Update)+'static>(&mut self, callback: F) {
        let cell = Rc::new(RefCell::new(callback));
        self.update_callbacks.borrow_mut().push(cell);
    }

    fn update(update_callbacks: &Rc<RefCell<Vec<Rc<RefCell<FnMut(Update)>>>>>, val: Update) {
        for callback in update_callbacks.borrow_mut().iter() {
            let mut closure = callback.borrow_mut();
            (&mut *closure)(val.clone());
        }
    }


    fn parse_message(message: &Message) -> Option<Update> {
        match message.view(){
            MessageView::Tag(tag) => {
                let taglist = tag.get_tags();
                match taglist.get::<gstreamer::tags::Title>(){
                    Some(title) => Some(Update::Title(title.get().unwrap().to_string())),
                    None => None
                }
            },
            MessageView::StateChanged(sc) => {
                info!("State: {:?}", sc.get_current());
                match sc.get_current(){
                    gstreamer::State::Playing => Some(Update::Playback(State::Playing)),
                    gstreamer::State::Paused => Some(Update::Playback(State::Loading)),
                    _ => Some(Update::Playback(State::Stopped)),
                }
            }
            _ => None,
        }
    }

    fn new_bus_messages (update_callbacks: Rc<RefCell<Vec<Rc<RefCell<FnMut(Update)>>>>>, bus: gstreamer::Bus){
        gtk::timeout_add(250, move ||{
            while(bus.have_pending()){
                match bus.pop(){
                    Some(message) => {
                        match Self::parse_message(&message){
                            Some(update) => Self::update(&update_callbacks, update),
                            None => (),
                        };
                    }
                    None => (),
                };
            }
            Continue(true)
        });
    }
}
