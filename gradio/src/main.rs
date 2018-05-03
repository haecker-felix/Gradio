#[macro_use] extern crate log;
extern crate pretty_env_logger;

extern crate gtk;
extern crate gio;
extern crate rustio;

mod app;
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
    let app = GradioApp::new();
    app.run();
}