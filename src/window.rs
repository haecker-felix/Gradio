use gtk::prelude::*;
use libhandy::LeafletExt;

use std::sync::mpsc::Sender;
use std::sync::Arc;

use crate::app::{Action, AppInfo};
use crate::widgets::notification::Notification;

#[derive(Debug, Clone, PartialEq)]
pub enum View {
    Search,
    Library,
}

#[derive(Debug, Clone, PartialEq)]
pub enum SidebarView {
    Playback,
    NoPlayback,
}

pub struct Window {
    pub widget: gtk::ApplicationWindow,
    pub player_box: gtk::Box,
    pub recorder_box: gtk::Box,
    pub library_box: gtk::Box,
    pub search_box: gtk::Box,

    builder: gtk::Builder,
    menu_builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Window {
    pub fn new(sender: Sender<Action>, appinfo: &AppInfo) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/window.ui");
        let menu_builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/menu.ui");

        let window: gtk::ApplicationWindow = builder.get_object("window").unwrap();
        let view_headerbar: gtk::HeaderBar = builder.get_object("view_headerbar").unwrap();
        window.set_title(&appinfo.app_name);

        let player_box: gtk::Box = builder.get_object("player_box").unwrap();
        let recorder_box: gtk::Box = builder.get_object("recorder_box").unwrap();
        let library_box: gtk::Box = builder.get_object("library_box").unwrap();
        let search_box: gtk::Box = builder.get_object("search_box").unwrap();

        let window = Self {
            widget: window,
            player_box,
            recorder_box,
            library_box,
            search_box,
            builder,
            menu_builder,
            sender,
        };

        // Appmenu / hamburger button
        let popover_menu: gtk::PopoverMenu = window.menu_builder.get_object("popover_menu").unwrap();
        let appmenu_button: gtk::MenuButton = window.builder.get_object("appmenu_button").unwrap();
        appmenu_button.set_popover(Some(&popover_menu));

        // Devel style class
        if appinfo.app_id.ends_with("Devel") {
            window.widget.get_style_context().map(|c| c.add_class("devel"));
        }

        window.setup_signals();
        window.set_view(View::Library);
        window
    }

    fn setup_signals(&self) {
        // add_button
        let add_button: gtk::Button = self.builder.get_object("add_button").unwrap();
        let sender = self.sender.clone();
        add_button.connect_clicked(move |_| {
            sender.send(Action::ViewShowSearch).unwrap();
        });

        // back_button
        let back_button: gtk::Button = self.builder.get_object("back_button").unwrap();
        let sender = self.sender.clone();
        back_button.connect_clicked(move |_| {
            sender.send(Action::ViewShowLibrary).unwrap();
        });

        let leaflet: libhandy::Leaflet = self.builder.get_object("content").unwrap();
        let bottombar: gtk::Box = self.builder.get_object("bottombar").unwrap();
        leaflet.connect_property_fold_notify(move |leaflet|{
            bottombar.set_visible(leaflet.get_property_folded());
        });
    }

    pub fn show_notification(&self, text: String) {
        let notification = Notification::new(text.as_str());

        let overlay: gtk::Overlay = self.builder.get_object("overlay").unwrap();
        notification.show(&overlay);
    }

    pub fn set_sidebar_view(&self, view: SidebarView){
        let sidebar_stack: gtk::Stack = self.builder.get_object("sidebar_stack").unwrap();

        match view{
            SidebarView::Playback => sidebar_stack.set_visible_child_name("playback"),
            SidebarView::NoPlayback => sidebar_stack.set_visible_child_name("no-playback")
        }
    }

    pub fn set_view(&self, view: View) {
        let sorting_mbutton: gtk::ModelButton = self.menu_builder.get_object("sorting_mbutton").unwrap();
        let library_mbutton: gtk::ModelButton = self.menu_builder.get_object("library_mbutton").unwrap();
        let view_stack: gtk::Stack = self.builder.get_object("view_stack").unwrap();
        let add_button: gtk::Button = self.builder.get_object("add_button").unwrap();
        let back_button: gtk::Button = self.builder.get_object("back_button").unwrap();

        // show or hide view specific buttons
        let library_mode = view == View::Library;
        add_button.set_visible(library_mode);
        back_button.set_visible(!library_mode);
        sorting_mbutton.set_sensitive(library_mode);
        library_mbutton.set_sensitive(library_mode);

        match view {
            View::Search => view_stack.set_visible_child_name("search"),
            View::Library => view_stack.set_visible_child_name("library"),
        }
    }
}
