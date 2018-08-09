extern crate gdk;
extern crate gio;
extern crate glib;
extern crate gtk;

use gtk::prelude::*;

use app_cache::AppCache;
use app_state::AppState;

use mdl::Model;

use page::library_page::LibraryPage;
use page::search_page::SearchPage;
use page::Page;

use widgets::playerbar::Playerbar;

pub struct Window{
    app_cache: AppCache,

    pub widget: gtk::ApplicationWindow,
    pub builder: gtk::Builder,

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

        let mut window = Self{
            app_cache,
            widget,
            builder,
            page_stack,
            library_page,
            search_page,
        };

        window.add_page(&window.library_page);
        window.add_page(&window.search_page);
        window.connect_signals();

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

    fn connect_signals(&mut self){
        // add_button
        let app_cache = self.app_cache.clone();
        let add_button: gtk::Button = self.builder.get_object("add_button").unwrap();
        add_button.connect_clicked(move |_| {
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{ a.gui_current_page = "search_page".to_string(); a.store(c); });
            app_cache.emit_signal("gui-current-page".to_string());
        });

        // back_button
        let app_cache = self.app_cache.clone();
        let back_button: gtk::Button = self.builder.get_object("back_button").unwrap();
        back_button.connect_clicked(move |_| {
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{ a.gui_current_page = "library_page".to_string(); a.store(c); });
            app_cache.emit_signal("gui-current-page".to_string());
        });

        // start_selection_mode_button
        let app_cache = self.app_cache.clone();
        let start_selection_mode_button: gtk::Button = self.builder.get_object("start_selection_mode_button").unwrap();
        let header_stack: gtk::Stack = self.builder.get_object("header_stack").unwrap();
        start_selection_mode_button.connect_clicked(move |_| {
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{ a.gui_selection_mode = true; a.store(c); });
            app_cache.emit_signal("gui-selection-mode".to_string());
        });

        // cancel_selection_mode_button
        let app_cache = self.app_cache.clone();
        let cancel_selection_mode_button: gtk::Button = self.builder.get_object("cancel_selection_mode_button").unwrap();
        let header_stack: gtk::Stack = self.builder.get_object("header_stack").unwrap();
        cancel_selection_mode_button.connect_clicked(move |_| {
            let c = &*app_cache.get_cache();
            AppState::get(c, "app").map(|mut a|{ a.gui_selection_mode = false; a.store(c); });
            app_cache.emit_signal("gui-selection-mode".to_string());

            header_stack.set_visible_child_name("default");
        });

        // Connect to "gui-selection-mode" signal
        let app_cache = self.app_cache.clone();
        let header_stack: gtk::Stack = self.builder.get_object("header_stack").unwrap();
        let bottom_stack: gtk::Stack = self.builder.get_object("bottom_stack").unwrap();
        self.app_cache.signaler.subscribe("gui-selection-mode", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();

            if(app_state.gui_selection_mode){
                header_stack.set_visible_child_name("selection_mode");
                bottom_stack.set_visible_child_name("selection_mode");
            }else{
                bottom_stack.set_visible_child_name("default");
                header_stack.set_visible_child_name("default");
            }
        })).unwrap();

        // Connect to "gui-current-page" signal
        let app_cache = self.app_cache.clone();
        let page_label: gtk::Label = self.builder.get_object("page_label").unwrap();
        let page_stack: gtk::Stack = self.builder.get_object("page_stack").unwrap();
        let header_button_stack: gtk::Stack = self.builder.get_object("header_button_stack").unwrap();
        self.app_cache.signaler.subscribe("gui-current-page", Box::new(move |sig| {
            let c = &*app_cache.get_cache();
            let app_state = AppState::get(c, "app").unwrap();
            debug!("Set page: {}", app_state.gui_current_page);

            if(app_state.gui_current_page == "library_page"){
                header_button_stack.set_visible_child_name("add");
                page_stack.set_visible_child_name("library_page");
                page_label.set_text("Library");
            }else{
                header_button_stack.set_visible_child_name("back");
            }

            if(app_state.gui_current_page == "search_page"){
                page_stack.set_visible_child_name("search_page");
                page_label.set_text("Add stations");
            }
        })).unwrap();
    }

}
