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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/search-page.ui")]
	public class SearchPage : Gtk.Box, Page{

		[GtkChild]
		Viewport ScrollViewport;

		private RowView row_view;
		private StationModel station_model;
		private StationProvider station_provider;

		private string search_text;

		// wait 1,3 seconds before spawning a new search thread
		private int search_delay = 1000;
		private uint delayed_changed_id;

		public SearchPage(){
			station_model =  new StationModel();
			row_view = new RowView(ref station_model);
			station_provider = new StationProvider(ref station_model);

			connect_signals();
			ScrollViewport.add(row_view);
		}

		private void connect_signals(){

		}

		public void set_search(string txt){
			search_text = txt;
			reset_timeout();
		}

		public string get_search(){
			return search_text;
		}

		private void reset_timeout(){
			if(delayed_changed_id > 0)
				Source.remove(delayed_changed_id);
			delayed_changed_id = Timeout.add(search_delay, timeout);
		}

		private bool timeout(){
			string address = RadioBrowser.radio_stations_by_name + search_text;

			message("Searching for \"%s\".", search_text);
			station_provider.set_address(address);

			delayed_changed_id = 0;

			return false;
		}
	}
}
