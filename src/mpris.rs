// extern crate dbus_macros;

// extern crate dbus;
// use dbus::{Connection, BusType, BusName, Path, NameFlag};

// use app::AppState;
// use std::cell::RefCell;
// use std::rc::Rc;

// use rustio::station::Station;
// use audioplayer::{Update, PlaybackState};
// use favicon_downloader::FaviconDownloader;

//
// WIP!
//

// dbus_class!("org.mpris.MediaPlayer2", class MprisRoot (variable: i32) {
//     fn Raise(&this) {}
//     fn CanRaise(&this) -> bool { true }

//     fn Quit(&this) {}
//     fn CanQuit(&this) -> bool { true }

//     fn Fullscreen(&this) {}
//     fn CanSetFullscreen(&this) -> bool { false }

//     fn HasTrackList(&this) -> bool { false }
//     fn Identity(&this) -> String { "Gradio" }
//     fn DesktopEntry(&this) -> String { "de.haeckerfelix.gradio" }
//     fn SupportedUriSchemes(&this) -> String { "" }
//     fn SupportedMimeTypes(&this) -> String { "" }
// });

// dbus_class!("org.mpris.MediaPlayer2.Player", class MprisPlayer (variable: i32) {

// });


// pub struct MPRIS{
//     app_state: Rc<RefCell<AppState>>,
// }

// impl MPRIS {
//     pub fn new(app_state: Rc<RefCell<AppState>>) -> Self {

//         let session_connection = Connection::get_private(BusType::Session).unwrap();
//         let hello = MprisRoot::new(24);

//         let mpris = Self {
//             app_state,
//         };

//         mpris.connect_signals();
//         mpris
//     }

//     fn connect_signals(&self){
//         let app_state = self.app_state.clone();
//         app_state.borrow_mut().player.register_update_callback(move |update|{
//             match update{
//                 Update::Station(station) => {

//                 },
//                 Update::Title(title) => {

//                 },
//                 Update::Playback(playback) => {
//                     match playback{
//                         PlaybackState::Playing => (),
//                         PlaybackState::Stopped => (),
//                         PlaybackState::Loading => (),
//                     };
//                 }
//             }
//         });
//     }
// }
