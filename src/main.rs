extern crate gtk;
extern crate gio;
extern crate glib;
extern crate gdk;
#[macro_use] extern crate log;
extern crate simplelog;
extern crate rustio;
extern crate libhandy;
extern crate gstreamer;
extern crate mpris_player;
extern crate rusqlite;

mod app;
mod window;
mod player;
mod library;
mod search;
mod widgets;
mod static_resource;

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
