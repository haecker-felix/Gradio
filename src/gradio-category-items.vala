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

	public class CategoryItems{
		public GenericModel languages_model;
		public GenericModel countries_model;
		public GenericModel states_model;

		public CategoryItems(){
			languages_model = new GenericModel();
			countries_model = new GenericModel();
			states_model = new GenericModel();
			load_lists.begin();
		}

		private async void load_lists (){
			Json.Parser parser = new Json.Parser ();
			Json.Node root = null;
			Json.Array items;
			string data = "";
			int max_items = 0;

			try{
				// Languages
				data = yield Util.get_string_from_uri(RadioBrowser.radio_station_languages);
				parser.load_from_data (data);
				root = parser.get_root ();
				items = root.get_array ();
				max_items = (int)items.get_length();
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
					GenericItem genericitem = new GenericItem(item_data.get_string_member("value"));
					languages_model.add_item(genericitem);
				}

				// Countries
				data = yield Util.get_string_from_uri(RadioBrowser.radio_station_countries);
				parser.load_from_data (data);
				root = parser.get_root ();
				items = root.get_array ();
				max_items = (int)items.get_length();
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
					GenericItem genericitem = new GenericItem(item_data.get_string_member("value"));
					countries_model.add_item(genericitem);
				}

				// States
				data = yield Util.get_string_from_uri(RadioBrowser.radio_station_states);
				parser.load_from_data (data);
				root = parser.get_root ();
				items = root.get_array ();
				max_items = (int)items.get_length();
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
					GenericItem genericitem = new GenericItem(item_data.get_string_member("value"));
					states_model.add_item(genericitem);
				}

				message("Loaded all category items.");
			}catch (Error e){
				critical("Could not load category items: %s", e.message);
			}
		 }
	}
}
