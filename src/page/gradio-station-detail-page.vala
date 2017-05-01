/* This file is part of Gradio.
 *
 * Gradio is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gradio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gradio.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/station-detail-page.ui")]
	public class StationDetailPage : Gtk.Box, Page{

		[GtkChild]
		private Stack DetailsStack;

		[GtkChild]
		private Label StationTitleLabel;
		[GtkChild]
		private Label StationLocationLabel;
		[GtkChild]
		private Label StationDescriptionLabel;
		[GtkChild]
		private Image StationImage;

		private TagBox tbox;

		[GtkChild]
		private Box RemoveBox;
		[GtkChild]
		private Box AddBox;

		[GtkChild]
		private Box PlayBox;
		[GtkChild]
		private Box StopBox;

		[GtkChild]
		private Box InformationBox;
		[GtkChild]
		private Label StationLikesLabel;
		[GtkChild]
		private ButtonBox ActionBox;

		private StationProvider similar_station_provider;
		private StationModel similar_station_model;

		[GtkChild]
		private Box Bottom;

		private RadioStation station;


		public StationDetailPage(){
			show_loading();

			setup_view();
		}

		public string get_title(){
			return station.title;
		}

		private void connect_signals(){
			station.played.connect(show_stop_box);
			station.stopped.connect(show_play_box);
			station.added_to_library.connect(show_remove_box);
			station.removed_from_library.connect(show_add_box);
			station.notify["icon"].connect(set_logo);
		}

		private void setup_view(){
			GroupBox action_group = new GroupBox("Available actions");
			action_group.add_widget(ActionBox);
			Bottom.pack_start(action_group);

			GroupBox description_group = new GroupBox("Description");
			description_group.add_widget(StationDescriptionLabel);
			Bottom.pack_start(description_group);

			GroupBox tags_group = new GroupBox("Tags");
			tbox = new TagBox();
			tags_group.add_widget(tbox);
			Bottom.pack_start(tags_group);

			//GroupBox similar_stations_group = new GroupBox("Similar Stations");
			//similar_station_model = new StationModel();
			//similar_station_provider = new StationProvider(ref similar_station_model, 12);
			//similar_btile_view = new TileView(ref similar_station_model);
			//similar_stations_group.add_widget(similar_btile_view);
			//Bottom.pack_start(similar_stations_group);
		}

		public RadioStation get_station(){
			return station;
		}

		public void set_station(RadioStation s){
			show_loading();
			station = s;

			reset_view();
			set_data();
		}

		private new void set_data(){
			// Disconnect old signals
			if(station != null){
				station.played.disconnect(show_stop_box);
				station.stopped.disconnect(show_play_box);
				station.added_to_library.disconnect(show_remove_box);
				station.removed_from_library.disconnect(show_add_box);
				station.notify["icon"].disconnect(set_logo);
			}

			//connect new signals
			connect_signals();

			// Play / Stop Button
			if(App.player.is_playing_station(station))
				show_stop_box();
			else
				show_play_box();

			// Add / Remove Button
			if(App.library.contains_station(station))
				show_remove_box();
			else
				show_add_box();

			// Title
			StationTitleLabel.set_text(station.title);

			// Tags
			tbox.set_tags(station.tags);

			// Location
			StationLocationLabel.set_text(station.country + " " + station.state);

			// Likes
			StationLikesLabel.set_text(station.votes);

			// Description
			AdditionalDataProvider.get_description.begin(station, (obj,res) => {
				string desc = AdditionalDataProvider.get_description.end(res);
				StationDescriptionLabel.set_text(desc);
				show_details();
			});

			// Show warning if some information is missing
			if(station.tags == "" || station.homepage == "" || station.icon_address == "" || station.title == "" || station.state == "" || station.country == "")
				InformationBox.set_visible(true);

			// Logo
			StationImage.set_from_pixbuf(Util.optiscale(station.pixbuf,192));

			// Similar Stations
			string address = RadioBrowser.radio_stations_by_name + station.title.substring(0, station.title.index_of(" "));
			similar_station_provider.set_address(address);
		}

		private void set_logo(){
			StationImage.set_from_pixbuf(Util.optiscale(station.pixbuf,192));
		}

		private void reset_view(){
			StationTitleLabel.set_text(" ");
			StationDescriptionLabel.set_text(" ");
			StationLocationLabel.set_text(" ");
			tbox.set_tags(" ");

			InformationBox.set_visible(false);
		}

		private void show_add_box(){
			AddBox.set_visible(true);
			RemoveBox.set_visible(false);
		}

		private void show_remove_box(){
			AddBox.set_visible(false);
			RemoveBox.set_visible(true);
		}

		private void show_play_box(){
			StopBox.set_visible(false);
			PlayBox.set_visible(true);
		}

		private void show_stop_box(){
			StopBox.set_visible(true);
			PlayBox.set_visible(false);
		}

		private void show_loading(){
			DetailsStack.set_visible_child_name("loading");
		}

		//TODO: implement a timeout, and maybe show this error message
		//private void show_error(){
		//	DetailsStack.set_visible_child_name("error");
		//}

		private void show_details(){
			if(StationDescriptionLabel.get_text() != "")
				DetailsStack.set_visible_child_name("details");
		}

		[GtkCallback]
		private void LikeButton_clicked(Button b){
			station.vote();
			StationLikesLabel.set_text(station.votes);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			if(App.player.current_station != null && App.player.current_station.id == station.id)
				App.player.toggle_play_stop();
			else
				App.player.set_radio_station(station);
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(station)){
				App.library.remove_radio_station(station);
			}else{
				App.library.add_radio_station(station);
			}
		}

		[GtkCallback]
		private void OpenHomepageButton_clicked(Button button){
			Util.open_website(station.homepage);
		}

		[GtkCallback]
		private void EditButton_clicked(Button button){
			Util.open_website("http://www.radio-browser.info/gui/#/edit/" + station.id);
		}
	}
}		
