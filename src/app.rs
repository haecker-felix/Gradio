extern crate gio;
extern crate gtk;
use gio::{ApplicationExt, ApplicationExtManual};
use gtk::prelude::*;

extern crate rustio;
use rustio::{audioplayer::AudioPlayer, client::Client};

use std::cell::RefCell;
use std::rc::Rc;

use page::library_page::LibraryPage;
use page::Page;
use page::test_page::TestPage;

pub struct GradioApp {
    pub player: Rc<RefCell<AudioPlayer>>,
    pub client: Rc<Client>,

    builder: gtk::Builder,
    gtk_app: gtk::Application,
    window: gtk::ApplicationWindow,
    page_stack: gtk::Stack,

    library_page: LibraryPage,
    test_page: TestPage,
}

impl GradioApp {
    pub fn new() -> GradioApp {
        let player = Rc::new(RefCell::new(AudioPlayer::new()));
        let client = Rc::new(Client::new());

        let builder = gtk::Builder::new_from_string(include_str!("window.ui"));
        let gtk_app = gtk::Application::new("de.haeckerfelix.Gradio", gio::ApplicationFlags::empty()).expect("Failed to initialize GtkApplication");
        let window: gtk::ApplicationWindow = builder.get_object("main_window").unwrap();
        let page_stack: gtk::Stack = builder.get_object("page_stack").unwrap();

        let library_page: LibraryPage = Page::new();
        page_stack.add_titled(library_page.container(), &library_page.name(), &library_page.title());
        let test_page: TestPage = Page::new();
        page_stack.add_titled(test_page.container(), &test_page.name(), &test_page.title());

        GradioApp {
            player,
            client,
            builder,
            gtk_app,
            window,
            page_stack,
            library_page,
            test_page,
        }
    }

    pub fn run(&self) {
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

        // Test Page
        let player = self.player.clone();
        let client = self.client.clone();
        self.test_page.connect_signals(&player, &client);
    }
}
