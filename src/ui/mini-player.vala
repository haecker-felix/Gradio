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


//
// This class is WIP.
//

using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/mini-player.ui")]
	public class MiniPlayer : Gtk.Box{

		[GtkChild]
		private Image PlayImage;
		[GtkChild]
		private Image StopImage;

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelCurrentTitleLabel;

		[GtkChild]
		private Image StationLogo;

		[GtkChild]
		private Image AddImage;
		[GtkChild]
		private Image RemoveImage;

		[GtkChild]
		private Label LikesLabel;

		[GtkChild]
		private VolumeButton VolumeButton;

		RadioStation station;

		public MiniPlayer(){
			App.player.played.connect (() => refresh_play_stop_button());
			App.player.stopped.connect (() => refresh_play_stop_button());
			App.player.tag_changed.connect (() => set_information());
			App.player.radio_station_changed.connect((t) => new_station(t));
			VolumeButton.set_value(Settings.volume_position);

		}

		private void new_station (RadioStation s){
			station = s;

			ChannelNameLabel.set_text(station.Title);
			ChannelCurrentTitleLabel.set_text("");

			StationLogo.set_from_icon_name("application-rss+xml-symbolic", IconSize.DND);

			refresh_add_remove_button();
			refresh_like_button();
			refresh_play_stop_button();

			this.set_visible(true);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
			refresh_play_stop_button();
		}

		[GtkCallback]
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			Settings.volume_position = value;
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(int.parse(station.ID)))
				App.library.remove_radio_station_by_id(int.parse(station.ID));
			else
				App.library.add_radio_station_by_id(int.parse(station.ID));

			refresh_add_remove_button();
		}

		[GtkCallback]
		private void LikeButton_clicked(Button button){
			station.vote();
			refresh_like_button();
		}

		[GtkCallback]
		private void OpenHomepageButton_clicked (Button button) {
			Util.open_website(station.Homepage);
		}

		private void set_information(){
			ChannelCurrentTitleLabel.set_text(App.player.tag_title);
		}

		private void refresh_like_button(){
			LikesLabel.set_text(station.Votes.to_string());
		}

		private void refresh_add_remove_button(){
			if(Gradio.App.library.contains_station(int.parse(station.ID))){
				AddImage.set_visible(false);
				RemoveImage.set_visible(true);
			}else{
				AddImage.set_visible(true);
				RemoveImage.set_visible(false);
			}
		}

		private void refresh_play_stop_button(){
			if(App.player.is_playing()){
				StopImage.set_visible(true);
				PlayImage.set_visible(false);
			}else{
				PlayImage.set_visible(true);
				StopImage.set_visible(false);
			}
		}
	}
}
