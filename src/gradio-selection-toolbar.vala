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

namespace Gradio{

	public enum SelectionMode {
		DEFAULT,
		LIBRARY,
		COLLECTION_OVERVIEW,
		COLLECTION_ITEMS
	}

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/selection-toolbar.ui")]
	public class SelectionToolbar : Gtk.Box{

		[GtkChild] private Gtk.Button AddToLibraryButton;
		[GtkChild] private Gtk.Button RemoveButton;
		[GtkChild] private Gtk.Button DetailsButton;
		[GtkChild] private Gtk.Button PlayButton;
		[GtkChild] private Gtk.Button CollectionButton;
		[GtkChild] private Gtk.Button VoteButton;

		private string collection_id = "";
		private int selected_items = 0;
		private SelectionMode mode;

		public SelectionToolbar(){
		}

		public void update_buttons(int count){
			selected_items = count;
			set_mode(mode);
		}

		public void set_mode(SelectionMode m, string cid = ""){
			mode = m;

			if(cid != "")
				collection_id = cid;

			// Set to standard
			RemoveButton.set_visible(false);
			DetailsButton.set_visible(false);
			AddToLibraryButton.set_visible(false);
			CollectionButton.set_visible(false);
			PlayButton.set_visible(true);
			VoteButton.set_visible(false);

			// if ONE item is selected
			bool single = false;
			if(selected_items <= 1) single = true;
			DetailsButton.set_visible(single);
			PlayButton.set_visible(single);
			VoteButton.set_visible(single);

			// If no item is selected, disabled all actions.
			if(selected_items == 0){
				RemoveButton.set_sensitive(false);
				DetailsButton.set_sensitive(false);
				AddToLibraryButton.set_sensitive(false);
				CollectionButton.set_sensitive(false);
				PlayButton.set_sensitive(false);
				VoteButton.set_sensitive(false);
			}else{
				RemoveButton.set_sensitive(true);
				DetailsButton.set_sensitive(true);
				AddToLibraryButton.set_sensitive(true);
				CollectionButton.set_sensitive(true);
				PlayButton.set_sensitive(true);
				VoteButton.set_sensitive(true);
			}

			switch(mode){
				case SelectionMode.DEFAULT: {
					AddToLibraryButton.set_visible(true);
					break;
				}
				case SelectionMode.LIBRARY: {
					RemoveButton.set_visible(true);
					CollectionButton.set_visible(true);
					break;
				}
				case SelectionMode.COLLECTION_OVERVIEW: {
					RemoveButton.set_visible(true);
					DetailsButton.set_visible(true);
					PlayButton.set_visible(false);
					VoteButton.set_visible(false);
					break;
				}
				case SelectionMode.COLLECTION_ITEMS: {
					RemoveButton.set_visible(true);
					CollectionButton.set_visible(true);
					break;
				}
			}
		}

		[GtkCallback]
		public void ShareButton_clicked (Gtk.Button button) {

		}

		[GtkCallback]
		public void CollectionButton_clicked (Gtk.Button button) {
			OrganizeCollectionDialog orgadiag = new OrganizeCollectionDialog();
			orgadiag.set_transient_for(App.window);
			orgadiag.set_modal(true);
			orgadiag.show_all();
		}

		[GtkCallback]
		public void RemoveButton_clicked (Gtk.Button button) {
			if(mode == SelectionMode.COLLECTION_OVERVIEW){
				CollectionModel model = (CollectionModel)App.window.get_collection_selection();
				for(int i = 0; i < model.get_n_items(); i++){
					Collection collection = (Collection)model.get_item(i);
					App.library.remove_collection(collection);
				}

			} else if(mode == SelectionMode.COLLECTION_ITEMS){
				StationModel model = (StationModel)App.window.get_station_selection();
				for(int i = 0; i < model.get_n_items(); i++){
					RadioStation station = (RadioStation)model.get_item(i);
					App.library.remove_station_from_collection(collection_id, station);
				}

			} else {
				StationModel model = (StationModel)App.window.get_station_selection();
				for(int i = 0; i < model.get_n_items(); i++){
					RadioStation station = (RadioStation)model.get_item(i);
					App.library.remove_radio_station(station);
				}
			}

			App.window.disable_selection_mode();
		}

		[GtkCallback]
		public void AddToLibraryButton_clicked (Gtk.Button button) {
			StationModel model = App.window.get_station_selection();
			App.window.disable_selection_mode();

			for(int i = 0; i < model.get_n_items(); i++){
				RadioStation station = (RadioStation)model.get_item(i);
				App.library.add_radio_station(station);
			}
		}

		[GtkCallback]
		public void DetailsButton_clicked (Gtk.Button button) {
			if(mode == SelectionMode.COLLECTION_OVERVIEW){
				CollectionModel model = (CollectionModel)App.window.get_collection_selection();
				for(int i = 0; i < model.get_n_items(); i++){
					Collection collection = (Collection)model.get_item(i);
					collection.show_details_dialog();
				}

			} else {
				StationModel model = (StationModel)App.window.get_station_selection();
				for(int i = 0; i < model.get_n_items(); i++){
					RadioStation station = (RadioStation)model.get_item(i);
					station.show_details_dialog();
				}
			}

			App.window.disable_selection_mode();
		}

		[GtkCallback]
		public void PlayButton_clicked (Gtk.Button button) {
			StationModel model = App.window.get_station_selection();
			App.window.disable_selection_mode();

			for(int i = 0; i < model.get_n_items(); i++){
				RadioStation station = (RadioStation)model.get_item(i);
				App.player.set_radio_station(station);
			}
		}

		[GtkCallback]
		public void VoteButton_clicked (Gtk.Button button) {
			StationModel model = App.window.get_station_selection();
			App.window.disable_selection_mode();

			for(int i = 0; i < model.get_n_items(); i++){
				RadioStation station = (RadioStation)model.get_item(i);
				station.vote();
			}
		}

	}
}
