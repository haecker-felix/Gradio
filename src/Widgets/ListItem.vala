using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/list-item.ui")]
	public class ListItem : Gtk.ListBoxRow{

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label LocationLabel;

		public RadioStation station;

		public ListItem(RadioStation s){
			station = s;

			load_information();
			station.data_changed.connect(() => load_information());
		}

		private void load_information(){
			ChannelNameLabel.set_text(station.Title);
			LocationLabel.set_text(station.Country + " " + station.State);
		}
	}
}

