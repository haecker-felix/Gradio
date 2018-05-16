#[macro_use]
extern crate log;
extern crate pretty_env_logger;

extern crate glib;
extern crate gio;
extern crate gtk;
extern crate rusqlite;
extern crate rustio;

mod app;
mod page;
mod library;
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
