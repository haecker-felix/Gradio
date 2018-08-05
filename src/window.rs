extern crate gdk;
extern crate gio;
extern crate glib;
extern crate gtk;

use gtk::prelude::*;

use app_cache::AppCache;
use page::library_page::LibraryPage;
use page::search_page::SearchPage;
use page::Page;

use widgets::playerbar::Playerbar;

pub struct Window{
    app_cache: AppCache,

    pub widget: gtk::ApplicationWindow,

    pub page_stack: gtk::Stack,
    pub library_page: LibraryPage,
    pub search_page: SearchPage,
}

impl Window{
    pub fn new(app_cache: AppCache) -> Self{
        Self::load_css();
        let builder = gtk::Builder::new_from_string(include_str!("window.ui"));

        let widget: gtk::ApplicationWindow = builder.get_object("main_window").unwrap();
        let page_stack: gtk::Stack = builder.get_object("page_stack").unwrap();
        let library_page: LibraryPage = Page::new(app_cache.clone());
        let search_page: SearchPage = Page::new(app_cache.clone());

        let playerbar_box: gtk::Box = builder.get_object("playerbar_box").unwrap();
        let playerbar = Playerbar::new(app_cache.clone());
        playerbar_box.add(&playerbar.container);

        let window = Self{
            app_cache,
            widget,
            page_stack,
            library_page,
            search_page,
        };

        window.add_page(&window.library_page);
        window.add_page(&window.search_page);

        window
    }

    fn add_page<P: Page>(&self, page: &P) {
        self.page_stack.add_titled(page.container(), &page.name(), &page.title());
    }

    fn load_css() {
        let provider = gtk::CssProvider::new();
        provider.load_from_data(include_str!("style.css").as_bytes());
        gtk::StyleContext::add_provider_for_screen(&gdk::Screen::get_default().unwrap(), &provider, 600);
    }

}
