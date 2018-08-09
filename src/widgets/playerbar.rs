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

use widgets::playbutton::Playbutton;

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

        let playbutton = Playbutton::new(app_cache.clone(), None);
        playbutton.container.set_property_height_request(40);
        let playbutton_box: gtk::Box = builder.get_object("playbutton_box").unwrap();
        playbutton_box.add(&playbutton.container);

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
        // Connect to "ap-station" signal
        let app_cache = self.app_cache.clone();
        let container = self.container.clone();
        let fdl = self.fdl.clone();
        let title_label: gtk::Label = self.builder.get_object("title_label").unwrap();
        let favicon_image: gtk::Image = self.builder.get_object("favicon_image").unwrap();
        self.app_cache.signaler.subscribe("ap-station", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

            match app_state.ap_station{
                Some(s) => {
                    container.set_visible(true);
                    title_label.set_text(&s.name);
                    favicon_image.set_from_icon_name("emblem-music-symbolic", 40);
                    fdl.set_favicon_async(&favicon_image, &s, 40);
                },
                None => (),
            }
        }));

        // Connect to "ap-title" signal
        let app_cache = self.app_cache.clone();
        let subtitle_label: gtk::Label = self.builder.get_object("subtitle_label").unwrap();
        let subtitle_revealer: gtk::Revealer = self.builder.get_object("subtitle_revealer").unwrap();
        self.app_cache.signaler.subscribe("ap-title", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

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
