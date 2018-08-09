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

pub struct StationRow {
    app_cache: AppCache,
    pub container: gtk::ListBoxRow,
    builder: gtk::Builder,
    station: Station,
}

impl StationRow {
    pub fn new(app_cache: AppCache, station: &Station) -> Self {
        let builder = gtk::Builder::new_from_string(include_str!("station_row.ui"));

        let container: gtk::ListBoxRow = builder.get_object("station_row").unwrap();
        let station_label: gtk::Label = builder.get_object("station_label").unwrap();
        let votes_label: gtk::Label = builder.get_object("votes_label").unwrap();
        let location_label: gtk::Label = builder.get_object("location_label").unwrap();
        let codec_label: gtk::Label = builder.get_object("codec_label").unwrap();
        let homepage_label: gtk::Label = builder.get_object("homepage_label").unwrap();
        let tags_label: gtk::Label = builder.get_object("tags_label").unwrap();
        let language_label: gtk::Label = builder.get_object("language_label").unwrap();

        let mut playbutton = Playbutton::new(app_cache.clone(), Some(station.clone()));
        let playbutton_box: gtk::Box = builder.get_object("playbutton_box").unwrap();
        playbutton_box.add(&playbutton.container);

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

        let row = Self {
            app_cache,
            container,
            builder,
            station: station.clone(),
        };
        row.connect_signals();
        row
    }

    fn connect_signals(&self) {
        // It's possible that app_state is still blocked, so let's try it again, till it's available.
        // let favicon_image: gtk::Image = self.builder.get_object("station_favicon").unwrap();
        // let station = self.station.clone();
        // let app_state = self.app_state.clone();
        // gtk::timeout_add(250, move ||{
        //     match app_state.try_borrow(){
        //         Ok(app_state) => {
        //             app_state.fdl.set_favicon_async(&favicon_image, &station, 32);
        //             Continue(false)
        //         },
        //         Err(_) => Continue(true),
        //     }
        // });

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

        let eventbox: gtk::EventBox = self.builder.get_object("eventbox").unwrap();
        let revealer: gtk::Revealer = self.builder.get_object("revealer").unwrap();
        let builder = self.builder.clone();
        let station = self.station.clone();
        eventbox.connect_button_press_event(move |_,_| {
            revealer.set_reveal_child(!revealer.get_reveal_child());
            gtk::Inhibit(true)
        });
    }
}
