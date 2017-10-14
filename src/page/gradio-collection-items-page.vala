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
		private StationModel station_model;
		private string title;

		public string collection_id;

		public CollectionItemsPage(){
			station_model =  new StationModel();
			mainbox = new MainBox();

			ScrollViewport.add(mainbox);
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});
		}

		public void set_collection(Collection coll){
			collection_id = coll.id;
			station_model = coll.station_model;
			mainbox.set_model(station_model);
		}

		public StationModel get_model(){
			return station_model;
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
			return title;
		}

		public void set_title(string t){
			title = t;
		}
	}
}


