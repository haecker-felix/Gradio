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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/collections-page.ui")]
	public class CollectionsPage : Gtk.Box, Page{

		[GtkChild] Viewport ScrollViewport;
		[GtkChild] Stack CollectionsStack;

		private MainBox mainbox;

		public Collection selected_collection;

		public CollectionsPage(){
			mainbox = new MainBox();
			mainbox.set_model(Library.collection_model);
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});

			ScrollViewport.add(mainbox);

			mainbox.item_activated.connect((t,a) => {
				Gd.MainBoxItem item = (Gd.MainBoxItem)a;

				if(Util.is_collection_item(int.parse(item.id))){
					Collection coll = (Collection)item;
					selected_collection = coll;
					App.window.set_mode(WindowMode.COLLECTION_ITEMS);

					App.window.details_box.set_collection(coll);
				}
			});

			Library.collection_model.items_changed.connect(() => {
				if(Library.collection_model.get_n_items() == 0)
					CollectionsStack.set_visible_child_name("empty");
				else
					CollectionsStack.set_visible_child_name("items");
			});
		}

		public void set_selection_mode(bool b){
			mainbox.set_selection_mode(b);
		}

		public void select_all(){
			mainbox.select_all();
		}

		public void select_none(){
			mainbox.unselect_all();
		}

		public GLib.List<Gd.MainBoxItem> get_selection(){
			return mainbox.get_selection();
		}
	}
}
