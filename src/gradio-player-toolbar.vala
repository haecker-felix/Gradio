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

		private StatusIcon status_icon;

		public PlayerToolbar(){
			setup_view();

			App.player.notify["state"].connect(station_state_changed);
			App.player.notify["current-title-tag"].connect (() => {
				if(!(App.player.current_title_tag == "" || App.player.current_title_tag == null)){
					StationMetadataLabel.set_text(App.player.current_title_tag);
					Util.send_notification(App.player.station.title, App.player.current_title_tag);
				}

			});
			App.player.notify["status-message"].connect (() => {
				if(App.player.current_title_tag == "" || App.player.current_title_tag == null)
					StationMetadataLabel.set_markup("<i>"+App.player.status_message+"</i>");
			});
			App.player.notify["station"].connect(() => {
				Idle.add(() => {
					station_changed();
					return false;
				});
			});

			if(App.player.station != null)
				station_changed();
		}

		private void setup_view(){
			this.pack_start(MediaControlBox);
			this.pack_start(StationLogoBox);
			this.pack_start(InfoBox);
			this.pack_end(VolumeBox);

			status_icon = new StatusIcon();
			StatusBox.pack_start(status_icon);
			this.show_all();

			VolumeButton.set_value(App.settings.volume_position);
		}

		private void station_changed (){
			// Title
			StationTitleLabel.set_text(App.player.station.title);

			Thumbnail _thumbnail = new Thumbnail.for_address(42, App.player.station.icon_address);
			_thumbnail.updated.connect(() => {
				StationLogo.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();
			StationLogo.set_tooltip_text(App.player.station.techinfo);

			this.set_visible(true);
		}

		private void station_state_changed(){
			if(App.player.state != Gst.State.NULL){
				StopImage.set_visible(true);
				PlayImage.set_visible(false);
			}else{
				StopImage.set_visible(false);
				PlayImage.set_visible(true);
			}
		}

		[GtkCallback]
        	private void VolumeButton_value_changed (double value) {
			App.player.volume = value;
			App.settings.volume_position = value;
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
		}

		[GtkCallback]
		private bool StationLogo_clicked(){
			App.window.details_box.set_station(App.player.station);
			App.window.details_box.set_visible(true);
			return false;
		}
	}
}

