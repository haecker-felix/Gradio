#[macro_use]
extern crate log;
extern crate pretty_env_logger;

#[macro_use]
extern crate serde_derive;


extern crate gdk;
extern crate gdk_pixbuf;
extern crate gio;
extern crate glib;
extern crate gtk;
extern crate reqwest;
extern crate gstreamer;
extern crate rusqlite;
extern crate rustio;
extern crate url;
extern crate mdl;

#[macro_use]
extern crate dbus_macros;
extern crate dbus;

mod gradio;
mod app_cache;
mod app_state;
mod window;
mod audioplayer;
mod favicon_downloader;
mod library;
mod page;
mod widgets;
mod mpris;

use gradio::GradioApp;

fn main() {
    // Init Logger
    pretty_env_logger::init();

    // Init GTK
    if gtk::init().is_err() {
        error!("Failed to init GTK.");
        return;
    }

    // Start Gradio itself
    let app = GradioApp::new();
    app.run();
}
