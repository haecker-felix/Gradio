using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/list-item.ui")]
	public class ListItem : Gtk.Box{

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelHomepageLabel;

		GradioApp app;
		RadioStation station;

		public ListItem(GradioApp a, RadioStation s){
			app = a;
			station = s;

			ChannelHomepageLabel.set_text(station.Homepage);
			ChannelNameLabel.set_text(station.Title);
		}

		[GtkCallback]
		private void PlayButton_clicked (Button button) {
			app.set_current_radio_station(station);
		}

		[GtkCallback]
		private void AddButton_clicked (Button button) {
			app.library.add_radio_station_by_id(int.parse(station.ID));
		}
	}
}
