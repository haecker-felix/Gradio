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
		private Label VotesLabel;
		[GtkChild]
		private Label LocationLabel;
		//[GtkChild]
		//private Label TagsLabel;

		RadioStation station;

		public ListItem(RadioStation s){
			station = s;

			load_information();

			App.library.added_radio_station.connect(() => refresh_add_remove_button());
			App.library.removed_radio_station.connect(() => refresh_add_remove_button());
			station.data_changed.connect(() => load_information());

			refresh_add_remove_button();
		}

		private void load_information(){
			ChannelNameLabel.set_text(station.Title);
			VotesLabel.set_text(station.Votes);
			LocationLabel.set_text(station.Country + " " + station.State);

			// TODO: Looking ugly. 
			//TagsLabel.set_text("(" + station.Tags + ")");
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

