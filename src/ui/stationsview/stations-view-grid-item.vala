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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/grid-item.ui")]
	public class GridItem : Gtk.FlowBoxChild{

		//public signal void clicked

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelLocationLabel;
		[GtkChild]
		private Label ChannelTagsLabel;
		[GtkChild]
		private Label LikesLabel;
		[GtkChild]
		private Image ChannelLogoImage;
		[GtkChild]
		private Image InLibraryImage;
		[GtkChild]
		private Box PlayBox;
		[GtkChild]
		private Box StopBox;
		[GtkChild]
		private Stack GridStack;

		public RadioStation station;

		public GridItem(RadioStation s){
			station = s;

			ChannelNameLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelNameLabel.set_max_width_chars(25);
			ChannelLocationLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelLocationLabel.set_max_width_chars(25);
			ChannelTagsLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelTagsLabel.set_max_width_chars(25);

			connect_signals();

			if(App.player.is_playing_station(station))
				StopBox.set_visible(true);
				PlayBox.set_visible(false);

			// Load basic information
			set_logo();
			ChannelNameLabel.set_text(station.Title);
			ChannelLocationLabel.set_text(station.Country + " " + station.State);
			ChannelTagsLabel.set_text(station.Tags);

			// Load advanced information
			refresh_information();
		}

		private void connect_signals(){
			station.played.connect(() => {
				StopBox.set_visible(true);
				PlayBox.set_visible(false);
			});

			station.stopped.connect(() => {
				StopBox.set_visible(false);
				PlayBox.set_visible(true);
			});
		}

		private void set_logo(){
			Gdk.Pixbuf icon = null;
			Gradio.App.imgprovider.get_station_logo.begin(station, 64, (obj, res) => {
		        	icon = Gradio.App.imgprovider.get_station_logo.end(res);

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);
				}
        		});
		}

		private void refresh_information(){
			// Show likes number
			LikesLabel.set_text(station.Votes.to_string());

			// Show star if station is in library
			if(Gradio.App.library.contains_station(station.ID)){
				InLibraryImage.set_visible(true);
			}
		}

		private void show_menu(bool b){
			if(b){
				GridStack.set_visible_child_name("actions");
			}else{
				GridStack.set_visible_child_name("info");
			}
		}

		[GtkCallback]
		private void LikeButton_clicked(Button b){
			station.vote();
			refresh_information();
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
        		if(App.player.current_station.ID == station.ID)
				App.player.toggle_play_stop();
			else
				App.player.set_radio_station(station);

			refresh_information();
		}

		[GtkCallback]
		private void BackButton_clicked(Button b){
			show_menu(false);
		}

		[GtkCallback]
		private bool GradioGridItem_clicked(Gdk.EventButton b){
			//right-click
			if(b.button == 3){
				refresh_information();
				show_menu(true);
			}


			return false;
		}
	}
}

