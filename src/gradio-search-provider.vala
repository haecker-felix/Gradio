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

	[DBus (name = "org.gnome.Shell.SearchProvider2")]
	public class SearchProvider : Object {

		[DBus (visible = false)] public signal void activate (uint32 timestamp, string station_id);
		[DBus (visible = false)] public signal void start_search (uint32 timestamp, string searchterm);

		private StationProvider station_provider;
		private StationModel station_model;

		public SearchProvider(){
			station_model = new StationModel();
			station_provider = new StationProvider(ref station_model);
		}

		private string array_to_string (string[] array){
			string result = "";

			foreach (string term in array) {
				string tmp = term + " ";
				result = result + tmp;
			}

			if(result.substring(result.length - 1) == " "){
				result = result.substring(0, result.length - 1);
			}

			return result;
		}

		private async string[] search_for_stations(string[] terms){
			station_model.clear();
			string searchterm = array_to_string(terms);
			message("Searching for \"%s\"", searchterm);

			HashTable<string, string> filter_table = new HashTable<string, string> (str_hash, str_equal);
			filter_table.insert("limit", App.settings.max_search_results.to_string());
			filter_table.insert("name", searchterm);
			filter_table.insert("order", "votes");
			filter_table.insert("reverse", "true");
			yield station_provider.get_stations("http://www.radio-browser.info/webservice/json/stations/search", filter_table);

			string[] results = {};
			for(int i = 0; i < station_model.get_n_items(); i++){
				RadioStation station = (RadioStation)station_model.get_item(i);
				results += station.id;
			}

			return results;
		}

		public async string[] get_initial_result_set (string[] terms) {
			return yield search_for_stations(terms);
		}

		public async string[] get_subsearch_result_set (string[] previous_results, string[] terms) {
			return yield search_for_stations(terms);
		}

		public HashTable<string, Variant>[] get_result_metas (string[] results) {
			var result = new GenericArray<HashTable<string, Variant>> ();

			foreach (var str in results) {
				RadioStation station = null;
				for(int i = 0; i < station_model.get_n_items(); i++){
					RadioStation tmp = (RadioStation)station_model.get_item(i);
					if(tmp.id == str){
						station = tmp;
						break;
					}
				}

				if(station == null) continue;

				var meta = new HashTable<string, Variant> (str_hash, str_equal);
				meta.insert ("id", str);
				meta.insert ("name", station.title);
				meta.insert ("icon", station.icon_address);
				meta.insert ("description", (station.country + " " + station.state));
				result.add (meta);
			}
			return result.data;
		}

		public void activate_result (string identifier, string[] terms, uint32 timestamp) {
			activate (timestamp, identifier);
		}

		public void launch_search (string[] terms, uint32 timestamp) {
			message("Launch search...");
			start_search(timestamp, array_to_string(terms));
		}
	}

}
