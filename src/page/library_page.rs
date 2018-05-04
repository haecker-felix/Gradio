extern crate gtk;
use gtk::prelude::*;

use page::page::Page;

pub struct LibraryPage {
    title: String,
    name: String,

    builder: gtk::Builder,
    container: gtk::Box,
}

impl LibraryPage {}

impl Page for LibraryPage {
    fn new() -> Self {
        let title = "Library".to_string();
        let name = "library_page".to_string();

        let builder = gtk::Builder::new_from_string(include_str!("library_page.ui"));
        let container: gtk::Box = builder.get_object("library_page").unwrap();

        Self { title, name, builder, container }
    }

    fn get_title(&self) -> &String {
        &self.title
    }

    fn get_name(&self) -> &String {
        &self.name
    }

    fn get_container(&self) -> &gtk::Box {
        &self.container
    }
}
