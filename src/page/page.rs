extern crate gtk;
use gtk::prelude::*;

pub trait Page {
    fn new() -> Self;

    fn get_title(&self) -> &String;
    fn get_name(&self) -> &String;
    fn get_container(&self) -> &gtk::Box;
}
