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
	public class StationProvider{

		private Soup.Session soup_session;
		private Json.Parser parser = new Json.Parser();

		private StationModel model = null;

		public signal void working();
		public signal void ready();

		public StationProvider(ref StationModel m) {
			model = m;

			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;
		}

		public async void get_stations (string address, HashTable<string,string> filter_table){
			// clear old search model
			model.clear();

			Soup.Message message = null;

			message = Soup.Form.request_new_from_hash("POST", address, filter_table);

			soup_session.queue_message (message, (session, msg) => {
		        	get_stations.callback ();
		    	});
			yield;

			yield parse_result((string)message.response_body.data);
			return;
		}

		private async void parse_result(string data){
			try{
				parser.load_from_data(data);

				var root = parser.get_root ();
				var radio_stations = root.get_array ();

				int items = (int)radio_stations.get_length();
				message("Search results found: %i", items);

				for(int i = 0; i < items; i++){
					var radio_station = radio_stations.get_element(i);
					var radio_station_data = radio_station.get_object ();

 					var station = new RadioStation.from_json_data(radio_station_data);
					model.add_item(station);
				}

				ready();

			}catch(GLib.Error e){
				warning ("Aborted parsing search results! " + e.message);
			}
        	}
	}

}

