extern crate gtk;

pub mod library_page;
pub mod search_page;

use app::AppState;
use std::cell::RefCell;
use std::rc::Rc;

pub trait Page {
    fn new(app_state: Rc<RefCell<AppState>>) -> Self;

    fn title(&self) -> &String;
    fn name(&self) -> &String;
    fn container(&self) -> &gtk::Box;
}
