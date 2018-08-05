extern crate gtk;
use gtk::prelude::*;

use app_cache::AppCache;
use app_state::AppState;
use mdl::Model;
use mdl::Signaler;
use std::cell::RefCell;
use std::rc::Rc;

use rustio::station::Station;
use audioplayer::PlaybackState;
use favicon_downloader::FaviconDownloader;

pub struct Playerbar {
    app_cache: AppCache,

    pub container: gtk::ActionBar,
    builder: gtk::Builder,

    fdl: Rc<FaviconDownloader>,
}

impl Playerbar {
    pub fn new(app_cache: AppCache) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("playerbar.ui"));
        let container: gtk::ActionBar = builder.get_object("playerbar").unwrap();

        let fdl = Rc::new(FaviconDownloader::new());

        let playerbar = Self {
            app_cache,
            container,
            builder,
            fdl,
        };

        playerbar.connect_signals();
        playerbar
    }

    fn connect_signals(&self){
        // start_playback_button
        let start_playback_button: gtk::Button = self.builder.get_object("start_playback_button").unwrap();
        let app_cache = self.app_cache.clone();
        start_playback_button.connect_clicked(move|_|{
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{
                a.ap_state = PlaybackState::Playing; a.store(c);
            });
            app_cache.emit_signal("ap".to_string());
        });


        // stop_playback_button
        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let app_cache = self.app_cache.clone();
        stop_playback_button.connect_clicked(move|_|{
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{
                a.ap_state = PlaybackState::Stopped; a.store(c);
            });
            app_cache.emit_signal("ap".to_string());
        });


        // Connect to "ap" to refresh the whole playerbar
        let app_cache = self.app_cache.clone();
        let container = self.container.clone();
        let fdl = self.fdl.clone();
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        let subtitle_label: gtk::Label = self.builder.get_object("subtitle_label").unwrap();
        let subtitle_revealer: gtk::Revealer = self.builder.get_object("subtitle_revealer").unwrap();
        let favicon_image: gtk::Image = self.builder.get_object("favicon_image").unwrap();
        let playback_stack: gtk::Stack = self.builder.get_object("playback_stack").unwrap();
        self.app_cache.signaler.subscribe("ap", Box::new(move |sig| {
            debug!("subscribed signal for ap");

            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

            // Playback
            match app_state.ap_state{
                PlaybackState::Playing => playback_stack.set_visible_child_name("stop_playback"),
                PlaybackState::Stopped => playback_stack.set_visible_child_name("start_playback"),
                PlaybackState::Loading => playback_stack.set_visible_child_name("loading"),
            }

            // Station
            match app_state.ap_station{
                Some(s) => {
                    container.set_visible(true);
                    title_label.set_text(&s.name);
                    favicon_image.set_from_icon_name("emblem-music-symbolic", 40);
                    fdl.set_favicon_async(&favicon_image, &s, 40);
                },
                None => (),
            }

            // Title
            match app_state.ap_title {
                Some(t) => {
                    subtitle_revealer.set_reveal_child(true);
                    subtitle_label.set_text(&t);
                },
                None => subtitle_revealer.set_reveal_child(false),
            }
        }));
    }
}
