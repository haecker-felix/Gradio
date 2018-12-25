#[macro_use]
extern crate log;
#[macro_use]
extern crate quick_error;

mod app;
mod library;
mod player;
mod recorder;
mod recorder_backend;
mod search;
mod static_resource;
mod station_model;
mod widgets;
mod window;

use crate::app::App;
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
