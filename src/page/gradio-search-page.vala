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

	public class SearchProvider{

		private const string address = "http://www.radio-browser.info/webservice/json/stations/search";
		private string search_term = "";

		Soup.Session soup_session;
		Json.Parser parser = new Json.Parser();

		StationModel model = null;
		FilterBox filterbox = null;

		// the maximum of stations to parse
		private int maximum = 100;

		public SearchProvider(ref StationModel m, ref FilterBox fb) {
			model = m;
			filterbox = fb;

			filterbox.information_changed.connect(set_search_request);

			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;

            		set_search_request();
		}

		public void set_search_term(string a){
			search_term = a;
			set_search_request();
		}

		private void set_search_request (){
			HashTable<string, string> table = new HashTable<string, string> (str_hash, str_equal);

			if(filterbox.selected_language != "")
				table.insert("language", filterbox.selected_language);

			if(filterbox.selected_country != "")
				table.insert("country", filterbox.selected_country);

			if(filterbox.selected_state != "")
				table.insert("state", filterbox.selected_state);

			table.insert("limit", "100");
			table.insert("name", search_term);
			Soup.Message msg = Soup.Form.request_new_from_hash("POST", address, table);

			soup_session.queue_message (msg, (sess, mess) => {
				stdout.printf ("Data: \n%s\n", (string) mess.response_body.data);
				model.clear();
				progress_request.begin((string) mess.response_body.data);
			});
		}

		private async void progress_request(string data){
			try{
				parser.load_from_data(data);

				var root = parser.get_root ();
				var radio_stations = root.get_array ();


				int items = (int)radio_stations.get_length();
				message("Items found: %i", items);

				if(items > maximum) items = maximum;

				for(int i = 0; i < items; i++){

					var radio_station = radio_stations.get_element(i);
					var radio_station_data = radio_station.get_object ();

					var station = new RadioStation.from_json_data(radio_station_data);
					model.add_station(station);
				}

			}catch(GLib.Error e){
				warning ("Aborted parsing! " + e.message);
			}
        	}
	}



	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/search-page.ui")]
	public class SearchPage : Gtk.Box, Page{

		[GtkChild] Viewport ScrollViewport;

		[GtkChild] private Box ResultsBox;
		[GtkChild] private Box FilterBox;
		[GtkChild] private SearchEntry SearchEntry;
		private FilterBox filterbox;

		private MainBox mainbox;
		private StationModel station_model;
		private SearchProvider search_provider;

		private string search_text;

		// wait 1,3 seconds before spawning a new search thread
		private int search_delay = 1000;
		private uint delayed_changed_id;

		private Dzl.StackList filter_stacklist;

		public SearchPage(){
			filterbox = new Gradio.FilterBox();
			FilterBox.add(filterbox);

			station_model =  new StationModel();
			station_model =  new StationModel();
			station_model =  new StationModel();
			search_provider = new SearchProvider(ref station_model, ref filterbox);

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
			message("New search request for \"%s\".", search_text);
			search_provider.set_search_term(search_text);

			delayed_changed_id = 0;
			return false;
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


