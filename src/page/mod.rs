pub mod library_page;
pub mod search_page;

extern crate gtk;
use app::AppState;
use gtk::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::mpsc::Sender;

pub trait Page {
    fn new(app_state: Rc<RefCell<AppState>>) -> Self;

    fn title(&self) -> &String;
    fn name(&self) -> &String;
    fn container(&self) -> &gtk::Box;
}
