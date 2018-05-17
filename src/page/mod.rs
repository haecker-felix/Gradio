pub mod library_page;
pub mod search_page;

extern crate gtk;
use gtk::prelude::*;
use app::Action;
use std::sync::mpsc::Sender;

pub trait Page {
    fn new(sender: Sender<Action>) -> Self;

    fn title(&self) -> &String;
    fn name(&self) -> &String;
    fn container(&self) -> &gtk::Box;
}
