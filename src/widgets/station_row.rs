extern crate gtk;
use gtk::prelude::*;

use app_cache::AppCache;
use app_state::AppState;
use audioplayer::PlaybackState;
use mdl::Model;
use rustio::station::Station;
use std::cell::RefCell;
use std::rc::Rc;
use widgets::playbutton::Playbutton;
use favicon_downloader::FaviconDownloader;

pub struct StationRow {
    app_cache: AppCache,
    pub container: gtk::ListBoxRow,
    builder: gtk::Builder,
    station: Station,

    gui_selection_mode_cb_id: u32,
}

impl StationRow {
    pub fn new(app_cache: AppCache, station: &Station, fdl: Rc<FaviconDownloader>) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_row.ui"));

        // gtk widgets
        let container: gtk::ListBoxRow = builder.get_object("station_row").unwrap();
        let station_label: gtk::Label = builder.get_object("station_label").unwrap();
        let votes_label: gtk::Label = builder.get_object("votes_label").unwrap();
        let location_label: gtk::Label = builder.get_object("location_label").unwrap();
        let codec_label: gtk::Label = builder.get_object("codec_label").unwrap();
        let homepage_label: gtk::Label = builder.get_object("homepage_label").unwrap();
        let tags_label: gtk::Label = builder.get_object("tags_label").unwrap();
        let language_label: gtk::Label = builder.get_object("language_label").unwrap();

        // playbutton
        let mut playbutton = Playbutton::new(app_cache.clone(), Some(station.clone()));
        let playbutton_box: gtk::Box = builder.get_object("playbutton_box").unwrap();
        playbutton_box.add(&playbutton.container);

        // set station favicon
        let favicon_image: gtk::Image = builder.get_object("station_favicon").unwrap();
        fdl.set_favicon_async(&favicon_image, &station, 32);

        // set station information
        station_label.set_text(&station.name);
        votes_label.set_text(&format!("{} Votes", station.votes));
        location_label.set_text(&format!("{} {}", station.country, station.state));
        codec_label.set_text(&station.codec);

        if station.homepage != "" {homepage_label.set_markup(&format!("<a href=\"{}\">{}</a>", station.homepage, station.homepage));
        }else{homepage_label.set_text("—");}

        if station.tags != "" {tags_label.set_text(&station.tags);
        }else{tags_label.set_text("—");}

        if station.language != "" {language_label.set_text(&station.language);
        }else{language_label.set_text("—");}

        let mut gui_selection_mode_cb_id = 0;

        let mut row = Self {
            app_cache,
            container,
            builder,
            station: station.clone(),
            gui_selection_mode_cb_id,
        };
        row.connect_signals();
        row
    }

    fn connect_signals(&mut self) {
        // let add_button: gtk::Button = self.builder.get_object("add_button").unwrap();
        // let station = self.station.clone();
        // let app_state = self.app_state.clone();
        // let builder = self.builder.clone();
        // add_button.connect_clicked(move |_| {
        //     app_state.borrow().library.add_station(&station, 0);
        // });

        // let remove_button: gtk::Button = self.builder.get_object("remove_button").unwrap();
        // let station = self.station.clone();
        // let app_state = self.app_state.clone();
        // let builder = self.builder.clone();
        // remove_button.connect_clicked(move |_| {
        //     app_state.borrow().library.remove_station(&station);
        // });

        // eventbox
        let app_cache = self.app_cache.clone();
        let eventbox: gtk::EventBox = self.builder.get_object("eventbox").unwrap();
        let check_button: gtk::CheckButton = self.builder.get_object("check_button").unwrap();
        let revealer: gtk::Revealer = self.builder.get_object("revealer").unwrap();
        let station = self.station.clone();
        eventbox.connect_button_press_event(move |_,button| {
            let c = &*app_cache.get_cache();
            let mut app_state = AppState::get(c, "app").unwrap();

            if(button.get_button() == 3){
                app_state.gui_selection_mode = true;
                app_state.store(c);
                app_cache.emit_signal("gui-selection-mode".to_string());
                check_button.set_active(true);
            }else{
                if(app_state.gui_selection_mode){
                    check_button.set_active(!check_button.get_active());
                }else{
                    revealer.set_reveal_child(!revealer.get_reveal_child());
                }
            }
            gtk::Inhibit(true)
        });

        // Connect to "gui-selection-mode" signal
        let app_cache = self.app_cache.clone();
        let selection_mode_revealer: gtk::Revealer = self.builder.get_object("selection_mode_revealer").unwrap();
        let revealer: gtk::Revealer = self.builder.get_object("revealer").unwrap();
        self.gui_selection_mode_cb_id = self.app_cache.signaler.subscribe("gui-selection-mode", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

            if(app_state.gui_selection_mode){
                selection_mode_revealer.set_reveal_child(true);
                revealer.set_reveal_child(false);
            }else{
                selection_mode_revealer.set_reveal_child(false);
            }
        })).unwrap();

        // disconnect from "gui-selection-mode" signal, when gtk widget is already destroyed
        let app_cache = self.app_cache.clone();
        let gui_selection_mode_cb_id = self.gui_selection_mode_cb_id.clone();
        self.container.connect_destroy(move|_|{
            app_cache.signaler.unsubscribe(gui_selection_mode_cb_id);
        });
    }
}
