extern crate gstreamer;
extern crate gtk;
use gstreamer::{Element, ElementFactory, ElementExt, Bus, Message, Continue, MessageView, State};
use gstreamer::prelude::*;
use rustio::station::Station;
use std::rc::Rc;
use std::sync::mpsc::{channel, Sender, Receiver};
use rustio::client::Client;

pub struct AudioPlayer{
    playbin: Element,
    client: Client,
    station: Option<Station>,

    playback_changed_cb: Vec<Box<Fn(&AudioPlayer)>>,
    station_changed_cb: Vec<Box<Fn(&AudioPlayer)>>,
}

enum BusNotification{
    Playback(bool)
}

impl AudioPlayer{
    pub fn new() -> AudioPlayer{
        gstreamer::init();

        let playbin = ElementFactory::make("playbin", "playbin").unwrap();
        let bus = playbin.get_bus().expect("Unable to get playbin bus");
        let client = Client::new();
        let station = None;

        let (bus_sender, bus_receiver) = channel();
        bus.add_watch(move|bus, message|{
            Self::bus_callback(&bus, &message, bus_sender.clone())
        });

        let ap = AudioPlayer{
            playbin,
            client,
            station,

            playback_changed_cb: Vec::new(),
            station_changed_cb: Vec::new(),
        };

        //ap.notification_loop(bus_receiver);
        ap
    }

    fn bus_callback(bus: &Bus, message: &Message, bus_sender: Sender<BusNotification>) -> Continue {
        match message.view(){
            MessageView::Tag(tag) => info!("tag"),
            MessageView::StateChanged(sc) => {
                match sc.get_current(){
                    State::Playing => bus_sender.send(BusNotification::Playback(true)),
                    _ => bus_sender.send(BusNotification::Playback(false)),
                };
            }
            _ => (),
        }
        Continue(true)
    }

    fn notification_loop(&self, bus_receiver: Receiver<BusNotification>){
        gtk::timeout_add(100, move||{
            match bus_receiver.try_recv().unwrap(){
                BusNotification::Playback(playback) => {
                    //Self::emit_cb(&self.playback_changed_cb);
                },
            };
            Continue(true)
        });
    }

    pub fn playback(&self) -> bool{
        if self.playbin.get_state(gstreamer::ClockTime::from_seconds(10)).1 == gstreamer::State::Playing{
            return true;
        }else{
            return false;
        }
    }

    pub fn set_playback(&mut self, play: bool){
        let ret = if play {
            info!("Start playback");
            self.playbin.set_state(gstreamer::State::Playing)
        }else{
            info!("Stop playback");
            self.playbin.set_state(gstreamer::State::Null)
        };
        debug!("gstreamer state is \"{:?}\"", ret);
        self.emit_playback_changed_cb();
    }

    pub fn station(&self) -> Option<Station> {
        self.station.clone()
    }

    pub fn set_station(&mut self, station: Station){
        let station_url = self.client.get_playable_station_url(&station);
        self.station = Some(station);

        self.playbin.set_state(gstreamer::State::Null);
        self.playbin.set_property("uri", &station_url);
        self.emit_station_changed_cb();
    }

    pub fn connect_playback_changed<F: Fn(&Self) + 'static>(&mut self, f: F){
        self.playback_changed_cb.push(Box::new(f));
    }

    fn emit_playback_changed_cb(&mut self){
        for x in 0..self.playback_changed_cb.len(){
            (*&self.playback_changed_cb[x])(self);
        }
    }

    pub fn connect_station_changed<F: Fn(&Self) + 'static>(&mut self, f: F){
        self.station_changed_cb.push(Box::new(f));
    }

    fn emit_station_changed_cb(&mut self){
        for x in 0..self.station_changed_cb.len(){
            (*&self.station_changed_cb[x])(self);
        }
    }

    fn emit_cb(vec: &Vec<Box<Fn(&AudioPlayer)>>){
        for x in 0..vec.len(){
            //(*&vec[x])();
        }
    }
}