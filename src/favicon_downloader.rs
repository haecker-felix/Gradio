extern crate glib;
extern crate reqwest;

extern crate gtk;
use gtk::prelude::*;

use gdk_pixbuf::Pixbuf;
use glib::Source;
use rustio::client::Client;
use rustio::error::Error;
use rustio::station::Station;
use std::collections::HashMap;
use std::env;
use std::fs;
use std::fs::File;
use std::io;
use std::io::BufWriter;
use std::io::Read;
use std::io::Write;
use std::path::PathBuf;
use std::rc::Rc;
use std::sync::Arc;
use std::sync::mpsc::Sender;
use std::sync::mpsc::channel;
use std::thread;
use url::{ParseError, Url};

pub struct FaviconDownloader {
    client: Arc<reqwest::Client>,
}

impl FaviconDownloader {
    pub fn new() -> Self {
        let client = Arc::new(Client::create_reqwest_client());

        FaviconDownloader { client: client }
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

    fn get_favicon_path(station: &Station, client: &reqwest::Client) -> Result<PathBuf, Error> {
        let mut path = Self::get_cache_path()?;
        path.push(&station.id);

        if !path.exists() {
            let url = Url::parse(&station.favicon)?;
            if url.cannot_be_a_base() {
                return Err(Error::ParseError);
            }
            let mut response = client.get(url).send()?;

            let mut file = File::create(&path)?;
            let mut buffer = Vec::new();
            response.read_to_end(&mut buffer);

            file.write_all(&buffer);
        }
        Ok(path)
    }

    fn get_pixbuf_from_path(path: PathBuf, size: i32) -> Option<Pixbuf> {
        match Pixbuf::new_from_file_at_size(path.as_path(), size, size) {
            Ok(pixbuf) => Some(pixbuf),
            Err(err) => {
                warn!("Could not get pixbuf from path \"{:?}\": {}", path, err);
                None
            }
        }
    }

    pub fn set_favicon_async(&self, gtkimage: gtk::Image, station: &Station, size: i32) {
        let station_clone = station.clone();
        let gtkimage = gtkimage.clone();
        let client = self.client.clone();
        let (sender, receiver) = channel();

        thread::spawn(move || {
            let result = Self::get_favicon_path(&station_clone, &client);
            sender.send(result);
        });

        gtk::timeout_add(100, move || {
            if gtkimage.get_parent() == None {
                debug!("Stop set_favicon_async_loop, source is already destroyed.");
                return Continue(false);
            }

            match receiver.try_recv() {
                Ok(ret) => {
                    let path: Option<PathBuf> = ret.ok().map(|path| path);
                    let pixbuf = path.map(|path| Self::get_pixbuf_from_path(path, size));

                    if pixbuf.is_some() {
                        pixbuf.unwrap().map(|ret| gtkimage.set_from_pixbuf(&ret));
                    }

                    Continue(false)
                }
                Err(err) => Continue(true),
            }
        });
    }
}
