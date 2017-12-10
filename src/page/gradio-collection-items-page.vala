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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/collection-items-page.ui")]
	public class CollectionItemsPage : Gtk.Box, Page{

		[GtkChild] Viewport ScrollViewport;

		private MainBox mainbox;
		private Collection collection;

		public CollectionItemsPage(){
			mainbox = new MainBox();
			collection = new Collection("", "");

			ScrollViewport.add(mainbox);
			collection.station_model.items_changed.connect(() => {title_changed();});
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});
		}

		public void set_collection(Collection coll){
			collection = coll;
			mainbox.set_model(collection.station_model);
		}

		public StationModel get_model(){
			return collection.station_model;
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

		public StationModel get_selection(){
			List<Gd.MainBoxItem> selection = mainbox.get_selection();
			StationModel model = new StationModel();

			foreach(Gd.MainBoxItem item in selection){
				model.add_item(item);
			}
			return model;
		}

		public string get_title(){
			return collection.name;
		}

		public string get_subtitle(){
			return _("Items: ") + collection.station_model.get_n_items().to_string();
		}
	}
}


