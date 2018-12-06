use gtk::prelude::*;

#[derive(Debug, Clone)]
pub struct Notification {
    revealer: gtk::Revealer,
    text_label: gtk::Label,
    close_button: gtk::Button,
}

impl Notification {
    pub(crate) fn new(text: &str) -> Self {
        let builder = gtk::Builder::new_from_resource("/de/haeckerfelix/Gradio/gtk/notification.ui");
        let revealer: gtk::Revealer = builder.get_object("revealer").unwrap();
        let close_button: gtk::Button = builder.get_object("close_button").unwrap();
        let text_label: gtk::Label = builder.get_object("text_label").unwrap();
        text_label.set_label(text);

        let notification = Notification {
            revealer,
            text_label,
            close_button,
        };

        let revealer = notification.revealer.clone();
        notification.close_button.connect_clicked(move |_| {
            revealer.set_reveal_child(false);
            revealer.destroy();
        });

        notification
    }

    pub fn show(&self, overlay: &gtk::Overlay) {
        overlay.add_overlay(&self.revealer);
        self.revealer.set_reveal_child(true);
    }
}
