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

		[GtkChild] Viewport ScrollViewport;

		[GtkChild] private Box ResultsBox;
		[GtkChild] private SearchEntry SearchEntry;
		[GtkChild] private ToggleButton FilterToggleButton;
		[GtkChild] private Revealer FilterRevealer;

		private MainBox mainbox;
		private StationModel station_model;
		private StationProvider station_provider;

		private string search_text;

		// wait 1,3 seconds before spawning a new search thread
		private int search_delay = 1000;
		private uint delayed_changed_id;

		public SearchPage(){
			station_model =  new StationModel();
			station_provider = new StationProvider(ref station_model);

			mainbox = new MainBox();
			mainbox.set_model(station_model);

			ResultsBox.add(mainbox);
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});

			connect_signals();
		}

		private void connect_signals(){
			SearchEntry.search_changed.connect(() => {
				string search_term = SearchEntry.get_text();

				if(search_term != "" && search_term.length >= 3){
					search_text = search_term;
					reset_timeout();
				}
			});
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

		public void set_selection_mode(bool b){
			mainbox.set_selection_mode(b);
		}

		public void select_all(){
			mainbox.select_all();
		}

		[GtkCallback]
		private void FilterToggleButton_toggled(){
			FilterRevealer.set_reveal_child(FilterToggleButton.get_active());
		}

		public void select_none(){
			mainbox.unselect_all();
		}

		public GLib.List<Gd.MainBoxItem> get_selection(){
			return mainbox.get_selection();
		}
	}
}


