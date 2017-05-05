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

		string address = "";
		string data = "";

		Soup.Session soup_session;
		Json.Parser parser = new Json.Parser();
		StationModel model = null;

		// the maximum of stations to parse
		private int maximum = 100;

		public StationProvider(ref StationModel m) {
			model = m;

			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;
		}

		public void set_address(string a){
			address = a;
			parse_data.begin ();
		}

		public void add_station_by_id(int id){
			Json.Parser parser = new Json.Parser ();
			RadioStation new_station = null;

			Util.get_string_from_uri.begin(RadioBrowser.radio_stations_by_id + id.to_string(), (obj, res) => {
				string data = Util.get_string_from_uri.end(res);

				if(data != ""){
					parser.load_from_data (data);
					var root = parser.get_root ();
					var radio_stations = root.get_array ();

					if(radio_stations.get_length() != 0){
						var radio_station = radio_stations.get_element(0);
						var radio_station_data = radio_station.get_object ();

						new_station = new RadioStation.from_json_data(radio_station_data);

						Idle.add(() => {
							model.add_station(new_station);
							return false;
						});
					}else{
						warning("Empty station data");
					}
				}
			});

		}

		private async void parse_data(){
			message ("Parsing data from \"%s\" ...", address);

			try{
				Soup.Request req = soup_session.request(address);
            			InputStream stream = yield req.send_async(null);
				yield parser.load_from_stream_async(stream);

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

}

