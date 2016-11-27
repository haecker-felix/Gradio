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
		private Label LikesLabel;

		private StatusLabel sl;

		RadioStation station = null;

		public PlayerToolbar(){
			this.pack_start(MediaControlBox);
			this.pack_start(StationLogoBox);
			this.pack_start(InfoBox);
			this.pack_end(ActionBox);

			sl = new StatusLabel();
			StatusBox.pack_start(sl);
			this.show_all();



			App.player.tag_changed.connect (() => set_information());
			App.player.radio_station_changed.connect(() => {
				Idle.add(() => {
					station_changed();
					return false;
				});
			});

		}


		private void show_stop_icon(){
			StopImage.set_visible(true);
			PlayImage.set_visible(false);
		}

		private void show_play_icon(){
			StopImage.set_visible(false);
			PlayImage.set_visible(true);
		}

		private void send_notification(string summary, string body){
			Util.send_notification(summary, body);
		}

		private void station_changed (){
			//disconnect old signals
			if(station != null){
				station.played.disconnect(show_stop_icon);
				station.stopped.disconnect(show_play_icon);
			}

		   	if(App.player.current_station != null)
				station = App.player.current_station;

			//connect new signals
			station.played.connect(show_stop_icon);
			station.stopped.connect(show_play_icon);

			if(station.is_playing)
				show_stop_icon();

			ChannelNameLabel.set_text(station.Title);
			ChannelCurrentTitleLabel.set_text("");

			StationLogo.set_from_icon_name("application-rss+xml-symbolic", IconSize.DND);
			Gdk.Pixbuf icon = null;

			Gradio.App.imgprovider.get_station_logo.begin(station, 41, (obj, res) => {
		        	icon = Gradio.App.imgprovider.get_station_logo.end(res);

				if(icon != null){
					StationLogo.set_from_pixbuf(icon);
				}else{
					StationLogo.set_from_icon_name("application-rss+xml-symbolic", IconSize.DND);
				}
        		});

			refresh_add_remove_button();
			refresh_like_button();

			this.set_visible(true);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(station.ID))
				App.library.remove_radio_station_by_id(station.ID);
			else
				App.library.add_radio_station_by_id(station.ID);

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

			if (Settings.show_notifications)
				if(App.player.tag_title != null)
					send_notification(station.Title, App.player.tag_title);
		}

		private void refresh_like_button(){
			LikesLabel.set_text(station.Votes.to_string());
		}

		private void refresh_add_remove_button(){
			if(Gradio.App.library.contains_station(station.ID)){
				AddImage.set_visible(false);
				RemoveImage.set_visible(true);
			}else{
				AddImage.set_visible(true);
				RemoveImage.set_visible(false);
			}
		}

	}
}
