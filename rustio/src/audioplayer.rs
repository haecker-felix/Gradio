extern crate gstreamer;
use gstreamer::{Element, ElementFactory, ElementExt};
use gstreamer::prelude::*;
use station::Station;
use client::Client;

pub struct AudioPlayer{
    playbin: Element,
    station_url: String,
}

impl AudioPlayer{
    pub fn new() -> AudioPlayer{
        gstreamer::init();
        let playbin = ElementFactory::make("playbin", "playbin").unwrap();
        AudioPlayer{
            playbin,
            station_url: "".to_string()
        }
    }

    pub fn set_playback(&self, play: bool){
        let ret = if play {
            info!("Start playback");
            self.playbin.set_state(gstreamer::State::Playing)
        }else{
            info!("Stop playback");
            self.playbin.set_state(gstreamer::State::Null)
        };
        debug!("gstreamer state is \"{:?}\"", ret);
    }

    pub fn set_station(&self, station: &Station){
        self.playbin.set_state(gstreamer::State::Null);
        let client = Client::new();
        let station_url = client.get_playable_station_url(&station);
        self.playbin.set_property("uri", &station_url);
    }
}