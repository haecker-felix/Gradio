extern crate gio;
extern crate gtk;
use gtk::prelude::*;
use gio::{ApplicationExtManual, ApplicationExt};

extern crate rustio;
use rustio::{client::Client, audioplayer::AudioPlayer};

use std::str::FromStr;
use std::rc::Rc;
use std::cell::RefCell;

pub struct GradioApp{
    pub player: Rc<RefCell<AudioPlayer>>,
    pub client: Rc<Client>,

    gtk_app: gtk::Application,
    window: gtk::ApplicationWindow,
    builder: gtk::Builder,
}

impl GradioApp {
    pub fn new() -> GradioApp {
        let player = Rc::new(RefCell::new(AudioPlayer::new()));
        let client = Rc::new(Client::new());

        let gtk_app = gtk::Application::new("de.haeckerfelix.Gradio", gio::ApplicationFlags::empty()).expect("Failed to initialize GtkApplication");
        let builder = gtk::Builder::new_from_string(include_str!("window.ui"));
        let window: gtk::ApplicationWindow = builder.get_object("main_window").unwrap();

        GradioApp{player, client, gtk_app, window, builder}
    }

    pub fn run(&self){
        self.connect_signals();
        self.gtk_app.run(&[]);
    }

    fn connect_signals(&self) {
        let get_button: gtk::Button = self.builder.get_object("get_button").unwrap();
        let stop_playback_button: gtk::Button = self.builder.get_object("stop_playback_button").unwrap();
        let start_playback_button: gtk::Button = self.builder.get_object("start_playback_button").unwrap();
        let id_entry: gtk::Entry = self.builder.get_object("id_entry").unwrap();
        let station_name_label: gtk::Label = self.builder.get_object("station_name_label").unwrap();
        let station_language_label: gtk::Label = self.builder.get_object("station_language_label").unwrap();
        let playable_url_label: gtk::Label = self.builder.get_object("playable_url_label").unwrap();

        // GTK Application activate
        let window_clone = self.window.clone();
        self.gtk_app.connect_activate(move|app| {
            app.add_window(&window_clone);
            debug!("gtk application activate");
        });

        // get_button clicked
        let player = self.player.clone();
        let client = self.client.clone();
        get_button.connect_clicked(move|_|{
            let station_id: i32 = FromStr::from_str(&id_entry.get_text().unwrap()).unwrap();

            let new_station = client.get_station_by_id(station_id);
            let playable_url = client.get_playable_station_url(&new_station);

            station_name_label.set_text(&new_station.name);
            station_language_label.set_text(&new_station.language);
            playable_url_label.set_text(&playable_url);

            player.borrow_mut().set_station_url(playable_url);
            //self.current_station = Some(new_station);
            info!("button clicked");
        });

        // start_playback_button clicked
        let player = self.player.clone();
        start_playback_button.connect_clicked(move|_|{
           player.borrow_mut().set_playback(true);
        });

        // stop_playback_button clicked
        let player = self.player.clone();
        stop_playback_button.connect_clicked(move|_|{
           player.borrow_mut().set_playback(false);
        });
    }
}