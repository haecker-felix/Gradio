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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/item/row-item.ui")]
	public class Row : Gtk.ListBoxRow, Item{

		[GtkChild]
		private Label StationTitleLabel;
		[GtkChild]
		private Label StationLikesLabel;
		[GtkChild]
		private Image StationLogoImage;

		[GtkChild]
		private Box PlayBox;
		[GtkChild]
		private Box StopBox;
		[GtkChild]
		private Box AddBox;
		[GtkChild]
		private Box RemoveBox;

		[GtkChild]
		private Box StationTags;
		private TagBox tbox;

		public RadioStation station;

		public Row(RadioStation s){
			station = s;
			tbox = new TagBox();
			tbox.set_max(4);
			StationTags.add(tbox);

			connect_signals();

			// Set information
			if(App.player.is_playing_station(station)){
				StopBox.set_visible(true);
				PlayBox.set_visible(false);
			}else{
				StopBox.set_visible(false);
				PlayBox.set_visible(true);
			}
			if(App.library.contains_station(station)){
				RemoveBox.set_visible(true);
				AddBox.set_visible(false);
			}else{
				RemoveBox.set_visible(false);
				AddBox.set_visible(true);
			}

			StationTitleLabel.set_text(station.Title);
			StationLikesLabel.set_text(station.Votes.to_string());
			set_logo();
			tbox.set_tags(station.Tags);
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

			station.added_to_library.connect(() => {
				AddBox.set_visible(false);
				RemoveBox.set_visible(true);
			});

			station.removed_from_library.connect(() => {
				AddBox.set_visible(true);
				RemoveBox.set_visible(false);
			});
		}

		private void set_logo(){
			//TODO: insert logo loader here
		}


		[GtkCallback]
		private void LikeButton_clicked(Button b){
			station.vote();
			StationLikesLabel.set_text(station.Votes.to_string());
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			if(App.player.current_station != null && App.player.current_station.ID == station.ID)
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

	}

}


