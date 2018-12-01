extern crate gdk;
extern crate gio;
extern crate glib;
extern crate gtk;
#[macro_use]
extern crate log;
extern crate gstreamer;
extern crate libhandy;
extern crate mpris_player;
extern crate rusqlite;
extern crate rustio;
extern crate simplelog;
extern crate indexmap;

mod app;
mod library;
mod player;
mod search;
mod static_resource;
mod widgets;
mod window;
mod station_model;

use app::App;
use simplelog::*;

fn main() {
    // Initialize logger
    SimpleLogger::init(LevelFilter::Debug, Config::default()).unwrap();

    // Initialize GTK
    gtk::init().unwrap_or_else(|_| panic!("Failed to initialize GTK."));
    static_resource::init().expect("Failed to initialize the resource file.");

    // Initialize Gstreamer
    gstreamer::init().expect("Failed to initialize Gstreamer");

    // Run app itself
    let app = App::new();
    app.run(app.clone());
}
