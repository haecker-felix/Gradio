extern crate gdk;
extern crate gio;
extern crate glib;
extern crate gtk;

use gio::{ApplicationExt, ApplicationExtManual};
use gtk::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

use rustio::{client::Client};

use favicon_downloader::FaviconDownloader;
use library::Library;
use audioplayer::AudioPlayer;

use page::library_page::LibraryPage;
use page::search_page::SearchPage;
use page::Page;

use widgets::playerbar::Playerbar;

pub struct AppState {
    pub library: Library,
    pub client: Client,
    pub player: AudioPlayer,
    pub fdl: FaviconDownloader,
}

pub struct AppUI {
    pub window: gtk::ApplicationWindow,

    pub page_stack: gtk::Stack,
    pub library_page: LibraryPage,
    pub search_page: SearchPage,
}

pub struct GradioApp {
    gtk_app: gtk::Application,

    app_state: Rc<RefCell<AppState>>,
    app_ui: Rc<RefCell<AppUI>>,
}

impl GradioApp {
    pub fn new() -> GradioApp {
        // Create App State
        let client = Client::new();
        let mut player = AudioPlayer::new();
        let fdl = FaviconDownloader::new();
        let library = Library::new();

        let app_state = Rc::new(RefCell::new(AppState { library, client, player, fdl }));
        Self::load_css();

        // Create App UI
        let builder = gtk::Builder::new_from_string(include_str!("window.ui"));

        let window: gtk::ApplicationWindow = builder.get_object("main_window").unwrap();
        let page_stack: gtk::Stack = builder.get_object("page_stack").unwrap();
        let library_page: LibraryPage = Page::new(app_state.clone());
        let search_page: SearchPage = Page::new(app_state.clone());

        let playerbar_box: gtk::Box = builder.get_object("playerbar_box").unwrap();
        let playerbar = Playerbar::new(app_state.clone());
        playerbar_box.add(&playerbar.container);

        let app_ui = Rc::new(RefCell::new(AppUI {
            window,
            page_stack,
            library_page,
            search_page,
        }));

        let gtk_app = gtk::Application::new("de.haeckerfelix.gradio", gio::ApplicationFlags::empty()).expect("Failed to initialize GtkApplication");
        glib::set_application_name("Radio");
        glib::set_prgname(Some("Radio"));

        GradioApp { gtk_app, app_state, app_ui }
    }

    fn add_page<P: Page>(&self, page: &P) {
        self.app_ui.borrow().page_stack.add_titled(page.container(), &page.name(), &page.title());
    }

    fn load_css() {
        let provider = gtk::CssProvider::new();
        provider.load_from_data(include_str!("style.css").as_bytes());
        gtk::StyleContext::add_provider_for_screen(&gdk::Screen::get_default().unwrap(), &provider, 600);
    }

    pub fn run(self) {
        self.add_page(&self.app_ui.borrow().library_page);
        self.add_page(&self.app_ui.borrow().search_page);

        self.app_ui.borrow().library_page.update_stations(&self.app_state.borrow().library.stations);

        let app_state = self.app_state.clone();

        self.connect_signals();
        self.gtk_app.run(&[]);
    }

    fn connect_signals(&self) {
        // GTK Application activate
        let window_clone = self.app_ui.borrow().window.clone();
        self.gtk_app.connect_activate(move |app| {
            app.add_window(&window_clone);
            debug!("gtk application activate");
        });
    }
}
