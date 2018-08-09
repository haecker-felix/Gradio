extern crate gdk;
extern crate gio;
extern crate glib;
extern crate gtk;

use rustio::{client::Client};
use app_state::AppState;
use app_cache::AppCache;
use window::Window;
use audioplayer::AudioPlayer;

use mdl::Model;
use gtk::prelude::*;
use gio::ApplicationExt;
use gio::ApplicationExtManual;

pub struct GradioApp{
    app_cache: AppCache,

    player: AudioPlayer,

    gtk_app: gtk::Application,
    window: Window,
}

impl GradioApp{
    pub fn new() -> Self {
        // Setup cache
        let app_cache = AppCache::new();

        // Initialize AppState if necessary, and store it in AppCache
        let ac = app_cache.clone();
        let c = &*ac.get_cache();
        match AppState::get(c, "app") {
            Ok(a) => debug!("Current application state:\n {:?}", a),
            Err(_) => {
                info!("Create new app state..");
                let app_state = AppState::new();
                app_state.store(c);
            }
        };

        let player = AudioPlayer::new(app_cache.clone());
        let gtk_app = gtk::Application::new("de.haeckerfelix.gradio", gio::ApplicationFlags::empty()).expect("Failed to initialize GtkApplication");
        let window = Window::new(app_cache.clone());

        app_cache.emit_all_signals();

        GradioApp {
            app_cache,
            player,
            gtk_app,
            window,
        }
    }

    pub fn run(&self) {
        self.connect_signals();
        self.gtk_app.run(&[]);
    }

    fn connect_signals(&self) {
        let window_clone = self.window.widget.clone();
        self.gtk_app.connect_activate(move |app| {
            app.add_window(&window_clone);
            debug!("gtk application activate");
        });
    }
}
