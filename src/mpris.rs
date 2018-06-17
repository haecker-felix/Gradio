extern crate mpris as m;
use m::Player;

extern crate dbus;
use dbus::{Connection, BusType, BusName, Path};

use app::AppState;
use std::cell::RefCell;
use std::rc::Rc;

use rustio::station::Station;
use audioplayer::{Update, State};
use favicon_downloader::FaviconDownloader;

pub struct MPRIS<'a>{
    app_state: Rc<RefCell<AppState>>,
    player: Player<'a>,
}

impl<'a>MPRIS<'a> {
    pub fn new(app_state: Rc<RefCell<AppState>>) -> Self {
        let connection = Connection::get_private(BusType::Session).unwrap();
        let busname = BusName::new("org.mpris.MediaPlayer2.gradio").unwrap();
        let path = Path::new("/org/mpris/MediaPlayer2").unwrap();

        let player = Player::new(connection, busname, path, 1000).unwrap();

        let mpris = Self {
            app_state,
            player,
        };

        mpris.connect_signals();
        mpris
    }

    fn connect_signals(&self){
        let app_state = self.app_state.clone();
        app_state.borrow_mut().player.register_update_callback(move |update|{
            match update{
                Update::Station(station) => {

                },
                Update::Title(title) => {

                },
                Update::Playback(playback) => {
                    match playback{
                        State::Playing => (),
                        State::Stopped => (),
                        State::Loading => (),
                    };
                }
            }
        });
    }
}
