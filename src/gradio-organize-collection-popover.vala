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
using Gd;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/collection-row.ui")]
	public class CollectionRow : ListBoxRow{

		[GtkChild] private Label CollectionLabel;
		[GtkChild] private Image AddedImage;

		public bool selected = false;
		public Collection collection;

		public CollectionRow (Collection coll){
			CollectionLabel.set_text(coll.name);
			collection = coll;

			if(App.window != null && App.window.current_selection != null){
				StationModel model = App.window.current_selection;
				if(model.get_n_items() != 0){
					RadioStation station = (RadioStation)model.get_item(0);
					Collection c = App.library.get_collection_by_station(station);
					if(c != null && c.name == coll.name) {
						selected = true;
						AddedImage.set_visible(selected);
					}
				}
			}

			this.show_all();
		}

		public void set_selected(bool b){
			selected = b;
			AddedImage.set_visible(selected);
		}
	}



	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/organize-collection-popover.ui")]
	public class OrganizeCollectionPopover : Gtk.Popover{

		[GtkChild] private Entry CreateEntry;
		[GtkChild] private Button CreateButton;

		[GtkChild] private ListBox CollectionsListBox;

		public OrganizeCollectionPopover(){
			CreateEntry.notify["text"].connect(() => {
				string text = CreateEntry.get_text();

				if(text.length > 2)
					CreateButton.set_sensitive(true);
				else
					CreateButton.set_sensitive(false);
			});

			CollectionsListBox.row_activated.connect((t,r) => {
				CollectionRow clicked_row = (CollectionRow)r;

				CollectionsListBox.forall((element) => { // deactivate other rows, except the clicked one
					if(((CollectionRow)element) != clicked_row)
						((CollectionRow)element).set_selected(false);
				});

				clicked_row.set_selected(!(clicked_row.selected)); // toggle the clicked one

				string destination_id = "0"; // remove it from a collection
				if(clicked_row.selected) destination_id = clicked_row.collection.id; // move it into a collection

				StationModel model = App.window.current_selection;
				foreach(Gd.MainBoxItem item in model){
					RadioStation station = (RadioStation)item;
					App.library.station_set_collection_id(station, destination_id);
				}
			});

			update_collections();
		}

		public void update_collections(){
			CollectionsListBox.forall((element) => CollectionsListBox.remove(element));

			StationModel collections = App.library.get_collections();
			foreach(Gd.MainBoxItem item in collections){
				Collection coll = (Collection) item;
				CollectionRow row = new CollectionRow(coll);
				CollectionsListBox.insert(row,0);
			}
		}

		[GtkCallback]
		private void CreateButton_clicked(Button button){
			Collection c = new Collection(CreateEntry.get_text(), Random.int_range(1000000, 9999999).to_string());
			App.library.add_collection(c);
			CreateEntry.set_text("");
			update_collections();
		}
	}
}
