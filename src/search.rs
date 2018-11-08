extern crate gtk;
use gtk::prelude::*;
use libhandy::{Leaflet, LeafletExt, LeafletModeTransitionType, LeafletChildTransitionType};

use std::sync::mpsc::Sender;

use app::Action;

pub struct Search{
    pub widget: gtk::Box,
    
    builder: gtk::Builder,
    sender: Sender<Action>,
}

impl Search{
    pub fn new(sender: Sender<Action>) -> Self{
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/search.ui");
        let widget: gtk::Box = builder.get_object("search").unwrap();    
        let content_box: gtk::Box = builder.get_object("content_box").unwrap();
        let sidebar_box: gtk::Box = builder.get_object("sidebar_box").unwrap();
        let stack_box: gtk::Box = builder.get_object("stack_box").unwrap();
        
        // Setup HdyLeaflet
        let leaflet = Leaflet::new();
        leaflet.set_mode_transition_type(LeafletModeTransitionType::Slide);
        leaflet.set_child_transition_type(LeafletChildTransitionType::Slide);
        content_box.add(&leaflet);
        
        let leaflet = leaflet.upcast::<gtk::Widget>(); // See https://gitlab.gnome.org/World/podcasts/blob/master/podcasts-gtk/src/widgets/home_view.rs#L64
        let leaflet = leaflet.downcast::<gtk::Container>().unwrap();
        leaflet.add(&sidebar_box);
        leaflet.add(&stack_box);
        leaflet.show();
        leaflet.set_vexpand(true);
        //leaflet.add(&library.collection_listbox.widget);    
    
        let search = Self{
            widget,
            builder,
            sender,
        };
        
        search.setup_signals();
        search
    }
    
    fn setup_signals(&self){

    }
}
