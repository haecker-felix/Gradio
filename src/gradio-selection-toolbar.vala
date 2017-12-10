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
		[GtkChild] private Gtk.Image InfoImage;

		[GtkChild] private Gtk.MenuButton RenameButton;
		[GtkChild] private Gtk.Entry RenameEntry;
		[GtkChild] private Gtk.Popover RenamePopover;

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
			InfoImage.set_visible(false);
			RenameButton.set_visible(false);

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
					RenameButton.set_visible(true);
				}
			}


			int library_count = library_items();
			int non_library_count = non_library_items();

			// Selection contains more library items than non library items
			if(library_count > non_library_count){
				RemoveButton.set_visible(true);

				// ... but no collection item!
				if(!window.current_selection.contains_collection_item())
					CollectionButton.set_visible(true);

				if(non_library_count != 0){
					InfoImage.set_visible(true);
					InfoImage.set_tooltip_text((_("%i radio station(s) not present in library.").printf(non_library_count)));
				}
			}

			// Selection contains more non library items than library items
			if(library_count <= non_library_count){
				AddButton.set_visible(true);

				if(library_count != 0){
					InfoImage.set_visible(true);
					InfoImage.set_tooltip_text((_("%i radio station(s) already added to library.").printf(library_count)));
				}
			}
		}

		private int non_library_items(){
			int count = 0;

			foreach(Gd.MainBoxItem item in window.current_selection){
				if(!App.library.contains_item(item)) count++;
			}

			return count;
		}

		private int library_items(){
			int count = 0;

			foreach(Gd.MainBoxItem item in window.current_selection){
				if(App.library.contains_item(item)) count++;
			}

			return count;
		}

		[GtkCallback]
		public void RemoveButton_clicked (Gtk.Button button) {
			StationModel selection = window.current_selection;

			foreach(Gd.MainBoxItem item in selection){
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

			foreach(Gd.MainBoxItem item in selection){
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

			if(!Util.is_collection_item(int.parse(item.id))){
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

		[GtkCallback]
		public void RenameSaveButton_clicked (Gtk.Button button) {
			Gd.MainBoxItem item = (Gd.MainBoxItem)window.current_selection.get_item(0);

			if(Util.is_collection_item(int.parse(item.id))){
				Collection collection = (Collection)item;
				App.library.rename_collection(collection, RenameEntry.get_text());
			}

			RenameEntry.set_text("");
			RenamePopover.hide();

			App.window.set_selection_mode(false);
		}
	}
}
