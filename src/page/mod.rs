extern crate gtk;

pub mod library_page;
pub mod search_page;

use app_cache::AppCache;
use std::cell::RefCell;
use std::rc::Rc;

pub trait Page {
    fn new(app_cache: AppCache) -> Self;

    fn title(&self) -> &String;
    fn name(&self) -> &String;
    fn container(&self) -> &gtk::Box;
}
