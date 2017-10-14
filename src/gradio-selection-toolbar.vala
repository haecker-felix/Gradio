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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/selection-toolbar.ui")]
	public class SelectionToolbar : Gtk.Box{

		[GtkChild] private Gtk.Button AddButton;
		[GtkChild] private Gtk.Button RemoveButton;
		[GtkChild] private Gtk.Button DetailsButton;
		[GtkChild] private Gtk.Button PlayButton;
		[GtkChild] private Gtk.MenuButton CollectionButton;
		[GtkChild] private Gtk.Button VoteButton;
		[GtkChild] private Gtk.Button EditButton;
		[GtkChild] private Gtk.Stack SelectionStack;
		private OrganizeCollectionPopover collection_dialog;

		private MainWindow window;

		public SelectionToolbar(MainWindow w){
			window = w;
			window.notify["current-selection"].connect(update_buttons);

			collection_dialog = new OrganizeCollectionPopover();
			CollectionButton.set_popover(collection_dialog);
			CollectionButton.toggled.connect(collection_dialog.update_collections);
		}

		private void update_buttons(){
			// Hide all buttons
			AddButton.set_visible(false);
			RemoveButton.set_visible(false);
			DetailsButton.set_visible(false);
			PlayButton.set_visible(false);
			CollectionButton.set_visible(false);
			VoteButton.set_visible(false);
			EditButton.set_visible(false);

			if(window.current_selection.get_n_items() == 0)
				SelectionStack.set_visible_child_name("no-actions");
			else
				SelectionStack.set_visible_child_name("actions");

			// Selection contains ONLY radio stations
			if(window.current_selection.contains_radio_station_item() && !window.current_selection.contains_collection_item()){
				if(window.current_selection.get_n_items() == 1){
					DetailsButton.set_visible(true);
					PlayButton.set_visible(true);
					VoteButton.set_visible(true);
					EditButton.set_visible(true);
				}
			}

			// Selection contains ONLY collections
			if(window.current_selection.contains_collection_item() && !window.current_selection.contains_radio_station_item()){
				if(window.current_selection.get_n_items() == 1){
					DetailsButton.set_visible(true);
					EditButton.set_visible(true);
				}
			}

			// Selection contains ONLY library items
			if(only_contains_library_items()){
				RemoveButton.set_visible(true);

				// ... but no collection item!
				if(!window.current_selection.contains_collection_item())
					CollectionButton.set_visible(true);
			}

			// Selection contains ONLY NON library items
			if(only_contains_non_library_items()){
				AddButton.set_visible(true);
			}
		}

		private bool only_contains_library_items(){
			// if count == 0, so it cannot contain any library item
			if(window.current_selection.get_n_items() == 0) return false;

			for(int i = 0; i < window.current_selection.get_n_items(); i++){
				Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(i);
				if(!App.library.contains_item(item)) return false;
			}

			return true;
		}

		private bool only_contains_non_library_items(){
			// if count == 0, so it cannot contain any non library item
			if(window.current_selection.get_n_items() == 0) return false;

			for(int i = 0; i < window.current_selection.get_n_items(); i++){
				Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(i);
				if(App.library.contains_item(item)) return false;
			}

			return true;
		}

		[GtkCallback]
		public void RemoveButton_clicked (Gtk.Button button) {
			StationModel selection = window.current_selection;

			for(int i = 0; i < selection.get_n_items(); i++){
				Gd.MainBoxItem item = (Gd.MainBoxItem)selection.get_item(i);

				if(Util.is_collection_item(int.parse(item.id)))
					App.library.remove_collection((Collection)item);
				else
					App.library.remove_radio_station((RadioStation)item);
			}

			App.window.set_selection_mode(false);
		}

		[GtkCallback]
		public void AddButton_clicked (Gtk.Button button) {
			StationModel selection = window.current_selection;

			for(int i = 0; i < selection.get_n_items(); i++){
				Gd.MainBoxItem item = (Gd.MainBoxItem)selection.get_item(i);

				if(!Util.is_collection_item(int.parse(item.id)))
					App.library.add_radio_station((RadioStation)item);
			}

			App.window.set_selection_mode(false);
		}

		[GtkCallback]
		public void DetailsButton_clicked (Gtk.Button button) {
			Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(0);

			if(Util.is_collection_item(int.parse(item.id))){
				Collection collection = (Collection)item;
				App.window.details_box.set_collection(collection);
			}else{
				RadioStation station = (RadioStation)item;
				App.window.details_box.set_station(station);
			}

			App.window.details_box.set_visible(true);
			App.window.set_selection_mode(false);
		}

		[GtkCallback]
		public void PlayButton_clicked (Gtk.Button button) {
			Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(0);

			if(!Util.is_collection_item(int.parse(item.id))){
				RadioStation station = (RadioStation)item;
				App.player.station = station;
			}

			App.window.set_selection_mode(false);
		}

		[GtkCallback]
		public void VoteButton_clicked (Gtk.Button button) {
			Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(0);

			// TODO: If you vote a station, instantly update likes value in the mainbox
			if(!Util.is_collection_item(int.parse(item.id))){
				RadioStation station = (RadioStation)item;
				station.vote();
			}

			App.window.set_selection_mode(false);
		}

		[GtkCallback]
		public void EditButton_clicked (Gtk.Button button) {
			Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(0);

			if(Util.is_collection_item(int.parse(item.id))){
				// TODO: make collections editable
				//StationEditorDialog editor_dialog = new StationEditorDialog.edit((Collection)item);
				//editor_dialog.set_transient_for(App.window);
				//editor_dialog.set_modal(true);
				//editor_dialog.set_visible(true);
			}else{
				StationEditorDialog editor_dialog = new StationEditorDialog.edit((RadioStation)item);
				editor_dialog.set_transient_for(App.window);
				editor_dialog.set_modal(true);
				editor_dialog.set_visible(true);
			}

			App.window.set_selection_mode(false);
		}

		[GtkCallback]
		public void ShareButton_clicked (Gtk.Button button) {
			// TODO: implement share button
		}
	}
}
