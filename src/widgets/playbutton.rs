extern crate gtk;
use gtk::prelude::*;

use app_cache::AppCache;
use app_state::AppState;
use mdl::Model;
use mdl::Signaler;
use std::cell::RefCell;
use std::rc::Rc;

use rustio::Station;
use audioplayer::PlaybackState;

pub struct Playbutton {
    app_cache: AppCache,

    pub container: gtk::Stack,
    builder: gtk::Builder,

    station: Option<Station>,
    ap_playback_cb_id: u32,
}

impl Playbutton {
    pub fn new(app_cache: AppCache, station: Option<Station>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("playbutton.ui"));
        let container: gtk::Stack = builder.get_object("playbutton").unwrap();

        let mut ap_playback_cb_id = 0;

        let mut playbutton = Self {
            app_cache,
            container,
            builder,
            station,
            ap_playback_cb_id,
        };

        playbutton.connect_signals();
        playbutton
    }

    fn connect_signals(&mut self){
        // set initial state of stack, we use gtk timeout here, otherwise arc/mutex is locked by sth else
        let playback_stack: gtk::Stack = self.container.clone();
        let app_cache = self.app_cache.clone();
        let station = self.station.clone();
        gtk::timeout_add(1, move ||{
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();
            let ps = playback_stack.clone();
            Self::set_state(app_state.ap_state, ps, station.clone(), app_state.ap_station.clone());
            gtk::Continue(false)
        });

        // start_playback_button
        let start_playback_button: gtk::Button = self.builder.get_object("start_playback_button").unwrap();
        let app_cache = self.app_cache.clone();
        let station = self.station.clone();
        start_playback_button.connect_clicked(move|_|{
            let c = &*app_cache.get_cache();
            let mut app_state = AppState::get(c, "app").unwrap();

            // playbutton in station row
            if(station.is_some()){
                let s = station.clone();
                app_state.ap_station = s;
                app_state.store(c);
                app_cache.emit_signal("ap-station".to_string());

            // playbutton is playerbar
            }else{
                app_state.ap_state = PlaybackState::SetPlaying;
                app_state.store(c);
                app_cache.emit_signal("ap-playback".to_string());
            }
        });


        // stop_playback_button
        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let app_cache = self.app_cache.clone();
        stop_playback_button.connect_clicked(move|_|{
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{
                a.ap_state = PlaybackState::SetStopped; a.store(c);
            });
            app_cache.emit_signal("ap-playback".to_string());
        });


        // Connect to "ap-playback" signal
        let app_cache = self.app_cache.clone();
        let playback_stack: gtk::Stack = self.container.clone();
        let station = self.station.clone();
        self.ap_playback_cb_id = self.app_cache.signaler.subscribe("ap-playback", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

            let ps = playback_stack.clone();
            Self::set_state(app_state.ap_state, ps, station.clone(), app_state.ap_station.clone());
        })).unwrap();

        // disconnect from ap-playback signal, when gtk widget is already destroyed
        let app_cache = self.app_cache.clone();
        let playback_stack: gtk::Stack = self.container.clone();
        let ap_playback_cb_id = self.ap_playback_cb_id.clone();
        playback_stack.connect_destroy(move|_|{
            app_cache.signaler.unsubscribe(ap_playback_cb_id);
        });
    }

    fn set_state(ap_state: PlaybackState, playback_stack: gtk::Stack, btn_station: Option<Station>, ap_station: Option<Station>){
        let mut set = false;

        if(btn_station.is_some() && ap_station.is_some()){
            if(ap_state != PlaybackState::Playing){
                playback_stack.set_visible_child_name("start_playback")
            }
            set = (btn_station.unwrap().url == ap_station.unwrap().url);
        }else{ set = true; }

        if(set){
             match ap_state{
                PlaybackState::Playing => playback_stack.set_visible_child_name("stop_playback"),
                PlaybackState::Stopped => playback_stack.set_visible_child_name("start_playback"),
                PlaybackState::Loading => playback_stack.set_visible_child_name("loading"),
                _ => (),
            }
        }
    }
}
