using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/list-item.ui")]
	public class ListItem : Gtk.Box{

		[GtkChild]
		private Image AddImage;
		[GtkChild]
		private Image RemoveImage;


		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelHomepageLabel;

		GradioApp app;
		RadioStation station;
		Library lib;

		public ListItem(ref GradioApp a, ref Library l, RadioStation s){
			app = a;
			station = s;
			lib = l;

			ChannelHomepageLabel.set_text(station.Homepage);
			ChannelNameLabel.set_text(station.Title);

			lib.added_radio_station.connect(() => refresh_add_remove_button());
			lib.removed_radio_station.connect(() => refresh_add_remove_button());

			refresh_add_remove_button();
		}

		[GtkCallback]
		private void PlayButton_clicked (Button button) {
			app.set_current_radio_station(station);
		}

		[GtkCallback]
		private void AddRemoveButton_clicked (Button button) {
			if(lib.contains_station(int.parse(station.ID))){
				lib.remove_radio_station_by_id(int.parse(station.ID));
			}else{
				lib.add_radio_station_by_id(int.parse(station.ID));
			}
		}

		private void refresh_add_remove_button(){
			if(lib.contains_station(int.parse(station.ID))){
				AddImage.set_visible(false);
				RemoveImage.set_visible(true);
			}else{
				AddImage.set_visible(true);
				RemoveImage.set_visible(false);
			}
		}
	}
}

