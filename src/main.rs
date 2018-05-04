#[macro_use]
extern crate log;
extern crate pretty_env_logger;

extern crate gio;
extern crate gtk;
extern crate rustio;

mod app;
mod page;
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
