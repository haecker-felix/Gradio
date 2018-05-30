pub mod library_page;
pub mod search_page;

extern crate gtk;
use gtk::prelude::*;
use std::sync::mpsc::Sender;
use std::rc::Rc;
use std::cell::RefCell;
use app::AppState;

pub trait Page {
    fn new(app_state: Rc<RefCell<AppState>>) -> Self;

    fn title(&self) -> &String;
    fn name(&self) -> &String;
    fn container(&self) -> &gtk::Box;
}
