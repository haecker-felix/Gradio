using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/action-popover.ui")]
	public class ActionPopover : Gtk.Popover{

		[GtkChild]
		private Image AddImage;
		[GtkChild]
		private Image RemoveImage;
		[GtkChild]
		private Label VotesLabel;

		RadioStation station;

		public ActionPopover(RadioStation s){
			station = s;

			load_information();

			App.library.added_radio_station.connect(() => refresh_add_remove_button());
			App.library.removed_radio_station.connect(() => refresh_add_remove_button());
			station.data_changed.connect(() => load_information());

			refresh_add_remove_button();
		}

		private void load_information(){
			VotesLabel.set_text(station.Votes);
		}

		[GtkCallback]
		private void HomepageButton_clicked (Button button) {
			Util.open_website(station.Homepage);
		}

		[GtkCallback]
		private void VoteButton_clicked (Button button) {
			station.vote();
		}

		[GtkCallback]
		private void PlayButton_clicked (Button button) {
			App.player.set_radio_station(station);
		}

		[GtkCallback]
		private void AddRemoveButton_clicked (Button button) {
			if(App.library.contains_station(int.parse(station.ID))){
				App.library.remove_radio_station_by_id(int.parse(station.ID));
			}else{
				App.library.add_radio_station_by_id(int.parse(station.ID));
			}
		}

		private void refresh_add_remove_button(){
			if(App.library.contains_station(int.parse(station.ID))){
				AddImage.set_visible(false);
				RemoveImage.set_visible(true);
			}else{
				AddImage.set_visible(true);
				RemoveImage.set_visible(false);
			}
		}
	}
}
