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
mod favicon_downloader;
mod library;
mod page;
mod station_listbox;
mod station_row;
use app::GradioApp;

fn main() {
    // Init Logger
    pretty_env_logger::init();

    // Init GTK
    if gtk::init().is_err() {
        error!("Failed to initialize GTK.");
        return;
    }

    // Run App
    let mut app = GradioApp::new();
    app.run();
}
