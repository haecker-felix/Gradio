extern crate gstreamer;
use gstreamer::{Element, ElementFactory, ElementExt};
use gstreamer::prelude::*;

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

    pub fn set_station_url(&mut self, url: String){
        info!("Set station url: {}", url);
        self.playbin.set_property("uri", &url);
    }
}