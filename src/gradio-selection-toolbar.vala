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
		[GtkChild] private Gtk.Button EditCollectionButton;
		[GtkChild] private Gtk.Button CollectionButton;

		private string collection_id = "";

		private SelectionMode mode;

		public SelectionToolbar(){

		}

		public void set_mode(SelectionMode m, string cid = ""){
			mode = m;
			collection_id = cid;

			RemoveButton.set_visible(false);
			EditCollectionButton.set_visible(false);
			AddToLibraryButton.set_visible(false);
			CollectionButton.set_visible(false);

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
					EditCollectionButton.set_visible(true);
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
			List<Gd.MainBoxItem> list = App.window.current_selection.copy();

			App.window.disable_selection_mode();

			list.foreach ((item) => {

				if(mode == SelectionMode.COLLECTION_ITEMS){
					Idle.add(() => {App.library.remove_station_from_collection(collection_id, (RadioStation)item); return false;});
				}else if(mode == SelectionMode.COLLECTION_OVERVIEW){
					Idle.add(() => {App.library.remove_collection((Collection)item); return false;});
				}else{
					Idle.add(() => {App.library.remove_radio_station((RadioStation)item); return false;});
				}

			});
		}

		[GtkCallback]
		public void AddToLibraryButton_clicked (Gtk.Button button) {
			List<Gd.MainBoxItem> list = App.window.current_selection.copy();

			App.window.disable_selection_mode();

			list.foreach ((station) => {
				App.library.add_radio_station((RadioStation)station);
			});
		}

	}
}
