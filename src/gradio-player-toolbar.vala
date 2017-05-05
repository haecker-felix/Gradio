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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/player-toolbar.ui")]
	public class PlayerToolbar : Gtk.ActionBar{

		[GtkChild]
		private Label StationTitleLabel;
		[GtkChild]
		private Label StationMetadataLabel;
		[GtkChild]
		private Image StationLogo;
		[GtkChild]
		private Label StationLikesLabel;


		[GtkChild]
		private Box StationLogoBox;
		[GtkChild]
		private Box MediaControlBox;
		[GtkChild]
		private Box InfoBox;
		[GtkChild]
		private Box ActionBox;
		[GtkChild]
		private Box StatusBox;


		[GtkChild]
		private Image AddImage;
		[GtkChild]
		private Image RemoveImage;

		[GtkChild]
		private Image PlayImage;
		[GtkChild]
		private Image StopImage;

		private StatusLabel sl;

		RadioStation station = null;

		public PlayerToolbar(){
			setup_view();

			App.player.tag_changed.connect (() => set_tag());
			App.player.radio_station_changed.connect(() => {
				Idle.add(() => {
					station_changed();
					return false;
				});
			});
		}

		private void setup_view(){
			this.pack_start(MediaControlBox);
			this.pack_start(StationLogoBox);
			this.pack_start(InfoBox);
			this.pack_end(ActionBox);

			sl = new StatusLabel();
			StatusBox.pack_start(sl);
			this.show_all();
		}

		private void station_changed (){
			//disconnect old signals
			if(station != null){
				station.played.disconnect(show_stop_icon);
				station.stopped.disconnect(show_play_icon);
				station.added_to_library.disconnect(show_remove_icon);
				station.removed_from_library.disconnect(show_add_icon);
			}

			// set new station
			if(App.player.current_station != null)
				station = App.player.current_station;

			//connect new signals
			station.played.connect(show_stop_icon);
			station.stopped.connect(show_play_icon);
			station.added_to_library.connect(show_remove_icon);
			station.removed_from_library.connect(show_add_icon);

			// Play / Stop Button
			if(App.player.is_playing_station(station))
				show_stop_icon();
			else
				show_play_icon();

			// Add / Remove Button
			if(App.library.contains_station(station))
				show_remove_icon();
			else
				show_add_icon();


			// Title
			StationTitleLabel.set_text(station.title);

			// Likes
			StationLikesLabel.set_text(station.votes.to_string());

			// Logo
                	App.image_cache.get_image.begin(station.icon_address, (obj, res) => {
		            	Gdk.Pixbuf pixbuf = App.image_cache.get_image.end(res);
		            	if (pixbuf != null) {
		                	StationLogo.clear();
		                	pixbuf = pixbuf.scale_simple(48, 48, Gdk.InterpType.BILINEAR);
		                	StationLogo.set_from_pixbuf(pixbuf);
		            	}
			});


			this.set_visible(true);
		}

		private void set_tag(){
			if(App.player.tag_title != null)
				StationMetadataLabel.set_text(App.player.tag_title);
		}

		private void show_stop_icon(){
			StopImage.set_visible(true);
			PlayImage.set_visible(false);
		}

		private void show_play_icon(){
			StopImage.set_visible(false);
			PlayImage.set_visible(true);
		}

		private void show_add_icon(){
			AddImage.set_visible(true);
			RemoveImage.set_visible(false);
		}

		private void show_remove_icon(){
			AddImage.set_visible(false);
			RemoveImage.set_visible(true);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(station))
				App.library.remove_radio_station(station);
			else
				App.library.add_radio_station(station);
		}

		[GtkCallback]
		private void LikeButton_clicked(Button button){
			station.vote();
			StationLikesLabel.set_text(station.votes.to_string());
		}

		[GtkCallback]
		private void ShowDetailsButton_clicked(Button button){
			Gradio.App.window.show_station_details(station);
		}
	}
}

