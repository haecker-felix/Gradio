#[macro_use]
extern crate log;
extern crate pretty_env_logger;

extern crate gdk;
extern crate gdk_pixbuf;
extern crate gio;
extern crate glib;
extern crate gtk;
extern crate reqwest;
extern crate rusqlite;
extern crate rustio;
extern crate url;

mod app;
mod page;
mod widgets;
mod library;
mod favicon_downloader;

use app::GradioApp;

fn main() {
    // Init Logger
    pretty_env_logger::init();

    // Init GTK
    if gtk::init().is_err() {
        error!("Failed to init GTK.");
        return;
    }

    // Run App
    let app = GradioApp::new();
    app.run();
}