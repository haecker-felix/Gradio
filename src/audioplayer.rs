extern crate gstreamer;
extern crate gtk;
extern crate glib;
use glib::prelude::*;
use gstreamer::{Element, ElementFactory, ElementExt, Bus, Message, Continue, MessageView, State};
use gstreamer::prelude::*;
use rustio::station::Station;
use std::rc::Rc;
use std::cell::RefCell;
use std::sync::mpsc::{channel, Sender, Receiver};
use rustio::client::Client;

pub struct AudioPlayer{
    playbin: Element,
    client: Client,
    station: Option<Station>,

    update_callbacks: Rc<RefCell<Vec<Rc<RefCell<FnMut(Update)>>>>>,
}

#[derive(Clone)]
pub enum Update{
    Playback(bool),
    Station(Station)
}

impl AudioPlayer{
    pub fn new() -> AudioPlayer{
        gstreamer::init();

        let playbin = ElementFactory::make("playbin", "playbin").unwrap();
        let bus = playbin.get_bus().expect("Unable to get playbin bus");
        let client = Client::new();
        let station = None;
        let update_callbacks = Rc::new(RefCell::new(Vec::new()));

        let update_cb_clone = update_callbacks.clone();
        gtk::timeout_add(250, move ||{
            while(bus.have_pending()){
                match bus.pop(){
                    Some(message) => {
                        match Self::parse_message(&message){
                            Some(update) => Self::update(&update_cb_clone, update),
                            None => (),
                        };
                    }
                    None => (),
                };
            }
            Continue(true)
        });

        AudioPlayer{
            playbin,
            client,
            station,
            update_callbacks,
        }
    }

    fn parse_message(message: &Message) -> Option<Update> {
        match message.view(){
            //MessageView::Tag(tag) => (),
            MessageView::StateChanged(sc) => {
                match sc.get_current(){
                    State::Playing => Some(Update::Playback(true)),
                    _ => Some(Update::Playback(false)),
                }
            }
            _ => None,
        }
    }

    pub fn set_playback(&mut self, play: bool){
        if play {
            debug!("Start playback...");
            self.playbin.set_state(gstreamer::State::Playing);
        }else{
            debug!("Stop playback...");
            self.playbin.set_state(gstreamer::State::Paused);
            self.playbin.set_state(gstreamer::State::Null);
        };
    }

    pub fn set_station(&mut self, station: Station){
        let station_url = self.client.get_playable_station_url(&station);
        Self::update(&self.update_callbacks, Update::Station(station.clone()));
        self.station = Some(station);

        self.playbin.set_state(gstreamer::State::Null);
        self.playbin.set_property("uri", &station_url);
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
}