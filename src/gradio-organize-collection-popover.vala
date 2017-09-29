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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/organize-collection-popover.ui")]
	public class OrganizeCollectionPopover : Gtk.Popover{

		[GtkChild] private Button AddButton;

		[GtkChild] private Entry CreateEntry;
		[GtkChild] private Button CreateButton;

		[GtkChild] private ListBox CollectionsListBox;

		public OrganizeCollectionPopover(){
			CollectionsListBox.set_header_func(header_func);
			connect_signals();
			update_collections();
		}

		private void connect_signals(){
			CreateEntry.notify["text"].connect(() => {
				string text = CreateEntry.get_text();

				// Don't add a collection with a same name, so we check it, before you can click the "+" button.
				// The ID is not needful here, so just ""
				Collection coll = new Collection(text, "");

				if(text.length > 2 && !(Library.station_model.contains_item(coll)))
					CreateButton.set_sensitive(true);
				else
					CreateButton.set_sensitive(false);
			});

			CollectionsListBox.row_activated.connect(() => {
				AddButton.set_sensitive(true);
			});

			this.closed.connect(update_collections);
		}

		private void update_collections(){
			CollectionsListBox.forall((element) => CollectionsListBox.remove(element));

			for (int i = 0; i < Library.station_model.get_n_items(); i ++) {
				Gd.MainBoxItem item = (Gd.MainBoxItem)Library.station_model.get_item (i);

				if(Util.is_collection_item(int.parse(item.id))){
					Collection coll = (Collection) item;
					insert_listbox_label(coll.name);
				}
			}
		}

		private void header_func(ListBoxRow row, ListBoxRow? row_before){
			if(row_before == null){
				row.set_header(null);
				return;
			}

			Gtk.Widget current = row.get_header();

			if(current == null){
				current = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
				current.show();
				row.set_header(current);
			}
		}

		private void insert_listbox_label(string text){
			Label label = new Label (text);
			label.halign = Align.START;
			label.height_request = 44;
			label.margin_start = 12;
			label.set_visible(true);
			CollectionsListBox.insert(label,0);
		}

		[GtkCallback]
		private void CreateButton_clicked(Button button){
			Collection c = new Collection(CreateEntry.get_text(), Random.int_range(1000000, 9999999).to_string()); 	// TODO: this should not be the right way to generate a id
			App.library.add_new_collection(c);
			CreateEntry.set_text("");
			insert_listbox_label(c.name);
		}

		[GtkCallback]
		private void AddButton_clicked(Button button){
			StationModel model = App.window.current_selection;
			App.window.set_selection_mode(false);

			ListBoxRow row = CollectionsListBox.get_selected_row();
			Label label = (Label)row.get_child();

			string n = label.get_text();

			message("Adding station(s) to collection \""+n+"\"");
			string id = Library.station_model.get_id_by_name(n);

			for(int i = 0; i < model.get_n_items(); i++){
				RadioStation station = (RadioStation)model.get_item(i);
				App.library.add_station_to_collection(id, station);

			}
		}
	}
}
