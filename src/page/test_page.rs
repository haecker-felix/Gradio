extern crate gtk;
use gtk::prelude::*;

use std::cell::RefCell;
use std::rc::Rc;
use std::str::FromStr;

use page::Page;
use rustio::{audioplayer::AudioPlayer, client::Client};

pub struct TestPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
}

impl TestPage {
    pub fn connect_signals(&self, app_player: &Rc<RefCell<AudioPlayer>>, app_client: &Rc<Client>) {
        let get_button: gtk::Button = self.builder.get_object("get_button").unwrap();
        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let start_playback_button: gtk::Button = self.builder.get_object("start_playback_button").unwrap();
        let id_entry: gtk::Entry = self.builder.get_object("id_entry").unwrap();
        let station_name_label: gtk::Label = self.builder.get_object("station_name_label").unwrap();
        let station_language_label: gtk::Label = self.builder.get_object("station_language_label").unwrap();
        let playable_url_label: gtk::Label = self.builder.get_object("playable_url_label").unwrap();

        // get_button clicked
        let player = app_player.clone();
        let client = app_client.clone();
        get_button.connect_clicked(move |_| {
            let station_id: i32 = FromStr::from_str(&id_entry.get_text().unwrap()).unwrap();

            let new_station = client.get_station_by_id(station_id);
            let playable_url = client.get_playable_station_url(&new_station);

            station_name_label.set_text(&new_station.name);
            station_language_label.set_text(&new_station.language);
            playable_url_label.set_text(&playable_url);

            player.borrow_mut().set_station_url(playable_url);
            info!("button clicked");
        });

        // start_playback_button clicked
        let player = app_player.clone();
        start_playback_button.connect_clicked(move |_| {
            player.borrow_mut().set_playback(true);
        });

        // stop_playback_button clicked
        let player = app_player.clone();
        stop_playback_button.connect_clicked(move |_| {
            player.borrow_mut().set_playback(false);
        });
    }
}

impl Page for TestPage {
    fn new() -> Self {
        let title = "Test/Debug".to_string();
        let name = "test_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("test_page.ui"));
        let container: gtk::Box = builder.get_object("test_page").unwrap();

        Self { title, name, builder, container }
    }

    fn title(&self) -> &String {
        &self.title
    }

    fn name(&self) -> &String {
        &self.name
    }

    fn container(&self) -> &gtk::Box {
        &self.container
    }
}
