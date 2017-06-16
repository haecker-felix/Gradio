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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/station-address-page.ui")]
	public class StationAddressPage : Gtk.Box, Page{

		[GtkChild] Viewport ScrollViewport;

		private MainBox mainbox;
		private StationModel station_model;

		private string address;
		private string title;

		public StationAddressPage(){
			station_model =  new StationModel();

			mainbox = new MainBox();
			mainbox.set_model(station_model);

			ScrollViewport.add(mainbox);
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});
		}

		public void set_address(string txt){
			address = txt;

			message("Showing stations for \"%s\".", address);
		}

		public string get_address(){
			return address;
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

		public string get_title(){
			return title;
		}

		public void set_title(string t){
			title = t;
		}
	}
}


