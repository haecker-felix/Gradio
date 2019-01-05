use gtk::prelude::*;
use libhandy::{ActionRow, ActionRowExt};

use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use std::rc::Rc;
use std::cell::RefCell;

#[derive(Debug, Clone)]
pub struct Song {
    pub widget: ActionRow,
    pub title: String,
    pub title_hash: String,
    pub path: String,
    pub duration: Rc<RefCell<u32>>, // in seconds

    save_button: gtk::Button,
    recording: Rc<RefCell<bool>>,
}

impl Song {
    pub fn new(title: &str) -> Self {
        let widget = ActionRow::new();
        widget.set_title(&title);
        widget.set_icon_name("");

        let save_button = gtk::Button::new();
        let save_image = gtk::Image::new_from_icon_name("document-save-symbolic", 4);
        save_button.add(&save_image);
        widget.add_action(&save_button);
        widget.show_all();

        let mut hasher = DefaultHasher::new();
        title.hash(&mut hasher);
        let title_hash = hasher.finish().to_string();

        let path = format!("{}/{}.ogg", glib::get_user_cache_dir().unwrap().to_str().unwrap(), title_hash);

        let song = Self {
            widget,
            title: title.to_string(),
            title_hash,
            path,
            duration: Rc::new(RefCell::new(0)),
            save_button,
            recording: Rc::new(RefCell::new(false)),
        };

        song.connect_signals();
        song.start();
        song
    }

    pub fn start(&self){
        *self.recording.borrow_mut() = true;

        let duration = self.duration.clone();
        let recording = self.recording.clone();
        gtk::timeout_add_seconds(1, move ||{
            *duration.borrow_mut() += 1;
            glib::Continue(*recording.borrow())
        });
    }

    pub fn stop(&self){
        *self.recording.borrow_mut() = false;

        let minutes = *self.duration.borrow() / 60;
        let seconds = *self.duration.borrow() % 60;
        self.widget.set_subtitle(&format!("{}:{}", minutes, seconds));
    }

    pub fn delete(&self){
        // TODO: implement
    }

    fn connect_signals(&self){
        let song = self.clone();
        self.save_button.connect_clicked(move |_|{
            if !*song.recording.borrow(){
                let new_path = format!("{}/{}.ogg", glib::get_user_special_dir(glib::UserDirectory::Music).unwrap().to_str().unwrap(), song.title);
                std::fs::copy(song.clone().path, new_path).expect("Could not save song");
            }else{
                warn!("Try to save song, but still recording!")
            }
        });
    }
}

impl PartialEq for Song {
    fn eq(&self, other: &Song) -> bool {
        self.title == other.title
    }
}
