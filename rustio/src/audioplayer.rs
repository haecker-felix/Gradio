extern crate gstreamer;
use gstreamer::{Element, ElementFactory, ElementExt};
use gstreamer::prelude::*;
use station::Station;
use client::Client;

pub struct AudioPlayer{
    playbin: Element,
    client: Client,
    station: Option<Station>,
}

impl AudioPlayer{
    pub fn new() -> AudioPlayer{
        gstreamer::init();
        let playbin = ElementFactory::make("playbin", "playbin").unwrap();
        let client = Client::new();
        let station = None;
        AudioPlayer{
            playbin,
            client,
            station,
        }
    }

    pub fn playback(&self) -> bool{
        if self.playbin.get_state(gstreamer::ClockTime::from_seconds(10)).1 == gstreamer::State::Playing{
            return true;
        }else{
            return false;
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

    pub fn station(&self) -> &Option<Station> {
        &self.station
    }

    pub fn set_station(&mut self, station: Station){
        let station_url = self.client.get_playable_station_url(&station);
        self.station = Some(station);

        self.playbin.set_state(gstreamer::State::Null);
        self.playbin.set_property("uri", &station_url);
    }
}