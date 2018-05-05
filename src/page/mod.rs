pub mod library_page;
pub mod test_page;

extern crate gtk;
use gtk::prelude::*;

pub trait Page {
    fn new() -> Self;

    fn title(&self) -> &String;
    fn name(&self) -> &String;
    fn container(&self) -> &gtk::Box;
}
