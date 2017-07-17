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

	public class SearchProvider{

		private const string address = "http://www.radio-browser.info/webservice/json/stations/search";

		// wait 1,3 seconds before spawning a new search
		private const int search_delay = 1000;
		private uint delayed_changed_id;

		private Soup.Session soup_session;
		private Json.Parser parser = new Json.Parser();

		private StationModel model = null;
		private FilterBox filterbox = null;

		// the maximum of stations to parse
		private int maximum = 100;

		public signal void working();
		public signal void ready();

		public SearchProvider(ref StationModel m, ref FilterBox fb) {
			model = m;
			filterbox = fb;

			filterbox.information_changed.connect(reset_timeout);
			App.window.station_sorting_changed.connect(reset_timeout);

			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;

			reset_timeout();
		}

		private void reset_timeout(){
			working();
			if(delayed_changed_id > 0)
				Source.remove(delayed_changed_id);
			delayed_changed_id = Timeout.add(search_delay, timeout);
		}

		private bool timeout(){
			message("Sending new search request to server");
			set_search_request();

			delayed_changed_id = 0;
			return false;
		}

		private void set_search_request (){
			// clear old search model
			model.clear();

			HashTable<string, string> table = new HashTable<string, string> (str_hash, str_equal);

			if(filterbox.selected_language != "" && filterbox.selected_language != null)
				table.insert("language", filterbox.selected_language);

			if(filterbox.selected_country != "" && filterbox.selected_country != null)
				table.insert("country", filterbox.selected_country);

			if(filterbox.selected_state != "" && filterbox.selected_state != null)
				table.insert("state", filterbox.selected_state);

			if(filterbox.search_term != "" && filterbox.search_term != null)
				table.insert("name", filterbox.search_term);

			string sort_by = "";
			switch(Settings.station_sorting){
				case Compare.VOTES: sort_by = "votes"; break;
				case Compare.NAME: sort_by = "name"; break;
				case Compare.LANGUAGE: sort_by = "language"; break;
				case Compare.COUNTRY: sort_by = "country"; break;
				case Compare.STATE: sort_by = "state"; break;
				case Compare.BITRATE: sort_by = "bitrate"; break;
				case Compare.CLICKS: sort_by = "clickcount"; break;
				case Compare.DATE: sort_by = "clicktimestamp"; break;
			}
			table.insert("order", sort_by);

			table.insert("reverse", (!Settings.sort_ascending).to_string());
			table.insert("limit", maximum.to_string());

			Soup.Message msg = Soup.Form.request_new_from_hash("POST", address, table);

			soup_session.queue_message (msg, (sess, mess) => {
				parse_result.begin((string) mess.response_body.data);
			});
		}

		private async void parse_result(string data){
			try{
				parser.load_from_data(data);

				var root = parser.get_root ();
				var radio_stations = root.get_array ();

				int items = (int)radio_stations.get_length();
				message("Search results found: %i", items);

				ready();

				for(int i = 0; i < items; i++){
					var radio_station = radio_stations.get_element(i);
					var radio_station_data = radio_station.get_object ();

					var station = new RadioStation.from_json_data(radio_station_data);
					model.add_station(station);
				}

			}catch(GLib.Error e){
				warning ("Aborted parsing search results! " + e.message);
			}
        	}
	}

}

