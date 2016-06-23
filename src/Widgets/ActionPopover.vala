using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/action-popover.ui")]
	public class ActionPopover : Gtk.Popover{

		[GtkChild]
		private Box AddBox;
		[GtkChild]
		private Box RemoveBox;
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

		[GtkCallback]
		private void EditButton_clicked (Button button) {
			StationEditorDialog editor = new StationEditorDialog(station);
			editor.set_transient_for(Gradio.App.window);
			editor.set_modal(true);
			editor.show();
		}

		private void refresh_add_remove_button(){
			if(App.library.contains_station(int.parse(station.ID))){
				AddBox.set_visible(false);
				RemoveBox.set_visible(true);
			}else{
				AddBox.set_visible(true);
				RemoveBox.set_visible(false);
			}
		}
	}
}
