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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/details-box.ui")]
	public class DetailsBox : Box {

		[GtkChild] private Box StationBox;
		[GtkChild] private Box CollectionBox;
		[GtkChild] private Box ActionBox;

		[GtkChild] private Label NameLabel;
		[GtkChild] private Label TypeLabel;

		[GtkChild] private Label ItemsLabel;

		[GtkChild] private Label TagsLabel;
		[GtkChild] private Label DescriptionLabel;
		[GtkChild] private Label LocationLabel;
		[GtkChild] private Label VotesLabel;

		[GtkChild] private Button OpenHomepageButton;
		[GtkChild] private Button EditButton;

		[GtkChild] private Image DetailImage;

		private RadioStation station;
		private Collection collection;

		public void set_station(RadioStation s){
			station = s;
			CollectionBox.set_visible(false);
			StationBox.set_visible(true);

			NameLabel.set_text(station.title);
			TypeLabel.set_text("Radio station");
			DescriptionLabel.set_text("...");
			TagsLabel.set_text(station.tags);
			LocationLabel.set_text(station.country + " " + station.state);
			VotesLabel.set_text(station.votes.to_string());

			// Description
			station.get_description.begin((obj,res) => {
				string desc = station.get_description.end(res);
				DescriptionLabel.set_text(desc);
			});

			OpenHomepageButton.set_visible(true);
			EditButton.set_visible(true);

			StationBox.set_visible(true);

			Thumbnail _thumbnail = new Thumbnail.for_station(100, station);
			_thumbnail.updated.connect(() => {
				DetailImage.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();

			ActionBox.set_visible(true);
		}

		public void set_collection(Collection c){
			collection = c;
			StationBox.set_visible(false);
			CollectionBox.set_visible(true);

			NameLabel.set_text(collection.name);
			TypeLabel.set_text("Collection");
			ItemsLabel.set_text(collection.station_model.get_n_items().to_string());

			CollectionBox.set_visible(true);

			Thumbnail _thumbnail = new Thumbnail.for_collection(100, collection);
			_thumbnail.updated.connect(() => {
				DetailImage.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();

			ActionBox.set_visible(false);
		}

		[GtkCallback]
		private void OpenHomepageButton_clicked(Button button){
			try{
				Gtk.show_uri(null, station.homepage, 0);
			}catch(Error e){
				warning(e.message);
			}
		}

		[GtkCallback]
		private void EditButton_clicked(Button button){
			StationEditorDialog editor_dialog = new StationEditorDialog.edit(station);
			editor_dialog.set_transient_for(App.window);
			editor_dialog.set_modal(true);
			editor_dialog.set_visible(true);
		}

		[GtkCallback]
		private void CloseButton_clicked(Button button){
			this.set_visible(false);
		}

		[GtkCallback]
		private void PlayButton_clicked(Button button){
			App.player.station = station;
		}
	}
}		
