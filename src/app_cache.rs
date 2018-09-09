extern crate glib;
extern crate gtk;

use gtk::prelude::*;
use mdl::cache::Cache;
use mdl::signal::SignalerSync;
use mdl::signal::SigType;
use mdl::Signaler;
use std::sync::Mutex;
use std::sync::MutexGuard;
use std::sync::Arc;

use std::io;
use std::fs;

#[derive(Clone)]
pub struct AppCache {
    cache: Arc<Mutex<Cache>>,
    pub signaler: SignalerSync,
}


impl AppCache {
    pub fn new() -> Self {
        let c = Cache::new(&Self::get_database_path().expect("Cannot access database")).expect("Cannot open/create cache");
        info!("Loaded database from {}", c.path);

        let cache = Arc::new(Mutex::new(c));
        let signaler = SignalerSync::new();

        // signal loop
        let s = signaler.clone();
        gtk::timeout_add(50, move ||{
            gtk::Continue(s.signal_loop_sync())
        });


        Self { cache, signaler }
    }

    pub fn get_cache(&self) -> MutexGuard<Cache> {
        match self.cache.try_lock() {
            Ok(mg) => mg,
            Err(_) => panic!("could not lock cache"),
        }
    }

    pub fn emit_all_signals(&self){
        self.emit_signal("gui-current-page".to_string());
        self.emit_signal("gui-selection-mode".to_string());
        self.emit_signal("ap-station".to_string());
        self.emit_signal("ap-title".to_string());
        self.emit_signal("ap-playback".to_string());
        self.emit_signal("library".to_string());
    }

    pub fn emit_signal(&self, signal: String){
        debug!("Emit signal: {}", signal);
        self.signaler.emit(SigType::Update, &signal);
    }

    fn get_database_path() -> io::Result<String> {
        let mut path = glib::get_user_data_dir().unwrap();
        debug!("User data dir: {:?}", path);

        if !path.exists() {
            info!("Create new user data directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio");
        if !path.exists() {
            info!("Create new data directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio.lmdb");
        return Ok(path.to_str().unwrap().to_string());
    }
}
