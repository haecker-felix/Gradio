extern crate gdk;
extern crate gio;
extern crate gtk;
use gio::{ApplicationExt, ApplicationExtManual};
use gtk::prelude::*;

use rustio::{audioplayer::AudioPlayer, client::Client};

use std::cell::RefCell;
use std::io::Read;
use std::rc::Rc;

use page::Page;
use page::library_page::LibraryPage;
use page::search_page::SearchPage;

use favicon_downloader::FaviconDownloader;
use library::Library;
use rustio::station::Station;
use std::fs::File;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::Sender;
use std::sync::mpsc::channel;

pub struct AppState {
    pub client: Client,
    pub player: AudioPlayer,
    pub fdl: FaviconDownloader,
}

pub struct GradioApp {
    library: Library,

    builder: gtk::Builder,
    gtk_app: gtk::Application,
    window: gtk::ApplicationWindow,

    page_stack: gtk::Stack,
    library_page: LibraryPage,
    search_page: SearchPage,

    playerbar: gtk::ActionBar,
    station_title: gtk::Label,
    station_subtitle: gtk::Label,

    app_state: Rc<RefCell<AppState>>,
}

impl GradioApp {
    pub fn new() -> GradioApp {
        // Create App State
        let client = Client::new();
        let player = AudioPlayer::new();
        let fdl = FaviconDownloader::new();

        let app_state = Rc::new(RefCell::new(AppState { client, player, fdl }));

        let library = Library::new(app_state.clone());

        // load custom stylesheet
        let provider = gtk::CssProvider::new();
        provider.load_from_data(include_str!("style.css").as_bytes());
        gtk::StyleContext::add_provider_for_screen(&gdk::Screen::get_default().unwrap(), &provider, 600);

        let builder = gtk::Builder::new_from_string(include_str!("window.ui"));
        let gtk_app = gtk::Application::new("de.haeckerfelix.Gradio", gio::ApplicationFlags::empty()).expect("Failed to initialize GtkApplication");
        let window: gtk::ApplicationWindow = builder.get_object("main_window").unwrap();
        let page_stack: gtk::Stack = builder.get_object("page_stack").unwrap();

        let library_page: LibraryPage = Page::new(app_state.clone());
        let search_page: SearchPage = Page::new(app_state.clone());

        library_page.update_stations(&library.stations);

        let playerbar: gtk::ActionBar = builder.get_object("playerbar").unwrap();
        playerbar.set_visible(false);
        let station_title: gtk::Label = builder.get_object("station_title").unwrap();
        let station_subtitle: gtk::Label = builder.get_object("station_subtitle").unwrap();

        GradioApp {
            library,
            builder,
            gtk_app,
            window,
            page_stack,
            library_page,
            search_page,
            playerbar,
            station_title,
            station_subtitle,
            app_state,
        }
    }

    fn add_page<P: Page>(&self, page: &P) {
        let page_stack: gtk::Stack = self.builder.get_object("page_stack").unwrap();
        page_stack.add_titled(page.container(), &page.name(), &page.title());
    }

    pub fn run(self) {
        self.add_page(&self.library_page);
        self.add_page(&self.search_page);

        self.connect_signals();
        self.gtk_app.run(&[]);
    }

    fn connect_signals(&self) {
        // GTK Application activate
        let window_clone = self.window.clone();
        self.gtk_app.connect_activate(move |app| {
            app.add_window(&window_clone);
            debug!("gtk application activate");
        });
    }
}
