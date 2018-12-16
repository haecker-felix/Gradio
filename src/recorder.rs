use gstreamer::prelude::*;
use gtk::prelude::*;
use mpris_player::{Metadata, MprisPlayer, OrgMprisMediaPlayer2Player, PlaybackStatus};
use rustio::{Client, Station};

use std::cell::Cell;
use std::rc::Rc;
use std::sync::mpsc::Sender;
use std::sync::Arc;
use std::thread;

use crate::app::{Action, AppInfo};

pub struct Recorder {
    pub widget: gtk::Box,

    filesink: gstreamer::Element,

    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Recorder {
    pub fn new(sender: Sender<Action>) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/recorder.ui");
        let widget: gtk::Box = builder.get_object("recorder").unwrap();

        let filesink = gstreamer::ElementFactory::make("filesink", "filesink").unwrap();

        let recorder = Self {
            widget,
            filesink,
            builder,
            sender,
        };

        recorder.setup_signals();
        recorder
    }

    fn setup_signals(&self) {

    }
}
