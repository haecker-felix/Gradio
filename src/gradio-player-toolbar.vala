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

		[GtkChild] private Label StationTitleLabel;
		[GtkChild] private Label StationMetadataLabel;
		[GtkChild] private Image StationLogo;


		[GtkChild] private Box StationLogoBox;
		[GtkChild] private Box MediaControlBox;
		[GtkChild] private Box InfoBox;
		[GtkChild] private Box StatusBox;
		[GtkChild] private Box VolumeBox;

		[GtkChild] private VolumeButton VolumeButton;

		[GtkChild] private Image PlayImage;
		[GtkChild] private Image StopImage;

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
			this.pack_end(VolumeBox);

			sl = new StatusLabel();
			StatusBox.pack_start(sl);
			this.show_all();

			VolumeButton.set_value(Settings.volume_position);
		}

		private void station_changed (){
			//disconnect old signals
			if(station != null){
				station.played.disconnect(show_stop_icon);
				station.stopped.disconnect(show_play_icon);
			}

			// set new station
			if(App.player.current_station != null)
				station = App.player.current_station;

			//connect new signals
			station.played.connect(show_stop_icon);
			station.stopped.connect(show_play_icon);

			// Play / Stop Button
			if(App.player.is_playing_station(station))
				show_stop_icon();
			else
				show_play_icon();


			// Title
			StationTitleLabel.set_text(station.title);

			Thumbnail _thumbnail = new Thumbnail.for_address(42, station.icon_address);
			_thumbnail.updated.connect(() => {
				StationLogo.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();


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

		[GtkCallback]
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			Settings.volume_position = value;
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
		}

		[GtkCallback]
		private bool StationLogo_clicked(){
			Gradio.App.window.show_station_details(station);
			return false;
		}
	}
}

