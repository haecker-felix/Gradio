extern crate glib;
extern crate reqwest;

use std::io;
use std::io::Read;
use std::io::BufWriter;
use std::fs::File;
use std::path::PathBuf;
use std::io::Write;
use std::fs;
use std::env;
use std::rc::Rc;
use std::collections::HashMap;
use std::sync::mpsc::Sender;
use app::Action;
use reqwest::Client;
use rustio::station::Station;
use rustio::error::Error;
use gdk_pixbuf::Pixbuf;

pub struct FaviconDownloader {
    client: Client,
}

impl FaviconDownloader {
    pub fn new() -> Self{
        let proxy: Option<String> = match env::var("http_proxy") {
            Ok(proxy) => Some(proxy),
            Err(error) => None,
        };

        let client = match proxy {
            Some(proxy_address) => {
                info!("Use Proxy: {}", proxy_address);
                let proxy = reqwest::Proxy::all(&proxy_address).unwrap();
                reqwest::Client::builder().proxy(proxy).build().unwrap()
            },
            None => reqwest::Client::new(),
        };

        FaviconDownloader {
            client: client,
        }
    }

    pub fn get_favicon_path(&self, station: &Station) -> Result<PathBuf, Error>{
        let mut path = Self::get_cache_path()?;
        path.push(&station.id);

        if !path.exists() {
            let mut response = self.client.get(&station.favicon).send()?;

            let mut file = File::create(&path)?;
            let mut buffer = Vec::new();
            response.read_to_end(&mut buffer);

            file.write_all(&buffer);
        }
        Ok(path)
    }

    fn get_cache_path() -> io::Result<PathBuf> {
        let mut path = glib::get_user_cache_dir().unwrap();

        if !path.exists() {
            info!("Create new user cache directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        path.push("gradio");
        if !path.exists() {
            info!("Create new cache directory...");
            fs::create_dir(&path.to_str().unwrap())?;
        }

        return Ok(path);
    }

    pub fn get_pixbuf(&self, station: &Station, size: i32) -> Option<Pixbuf>{
        let favicon_path = self.get_favicon_path(&station);
        match favicon_path{
            Ok(path) => {
                match Pixbuf::new_from_file_at_size(path.as_path(), size, size){
                    Ok(pixbuf) => Some(pixbuf),
                    Err(err) => {warn!("Could not get pixbuf for station \"{}\": {}", station.name, err); None},
                }
            },
            Err(err) => None,
        }
    }
}