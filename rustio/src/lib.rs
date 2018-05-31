#[macro_use] extern crate serde_derive;
#[macro_use] extern crate log;
#[macro_use] extern crate failure;
extern crate serde;
extern crate serde_json;
extern crate reqwest;
extern crate gstreamer;
extern crate gtk; // TODO: Don't require gtk

pub mod error;
pub mod client;
pub mod audioplayer;
pub mod station;
pub mod country;
pub mod state;
pub mod language;
pub mod tag;
pub mod stats;

