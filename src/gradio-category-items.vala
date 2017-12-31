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
		public Gtk.ListStore languages_model;
		public Gtk.ListStore countries_model;
		public Gtk.ListStore states_model;
                public Gtk.ListStore tags_model;

		public CategoryItems(){
			languages_model = new Gtk.ListStore(2, typeof(string), typeof(int));
			countries_model = new Gtk.ListStore(2, typeof(string), typeof(int));
			states_model = new Gtk.ListStore(2, typeof(string), typeof(int));
                        tags_model = new Gtk.ListStore(2, typeof(string), typeof(int));
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
                                Gtk.TreeIter language_iter;
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
                                        languages_model.append(out language_iter);
                                        languages_model.set(language_iter, 0, item_data.get_string_member("value"), 1, item_data.get_int_member("stationcount"));
				}

				// Countries
				data = yield Util.get_string_from_uri(RadioBrowser.radio_station_countries);
				parser.load_from_data (data);
				root = parser.get_root ();
				items = root.get_array ();
				max_items = (int)items.get_length();
                                Gtk.TreeIter country_iter;
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
                                        countries_model.append(out country_iter);
                                        countries_model.set(country_iter, 0, item_data.get_string_member("value"), 1, item_data.get_int_member("stationcount"));
				}

				// States
				data = yield Util.get_string_from_uri(RadioBrowser.radio_station_states);
				parser.load_from_data (data);
				root = parser.get_root ();
				items = root.get_array ();
				max_items = (int)items.get_length();
                                Gtk.TreeIter state_iter;
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
                                        states_model.append(out state_iter);
                                        states_model.set(state_iter, 0, item_data.get_string_member("value"), 1, item_data.get_int_member("stationcount"));
				}

				// Tags
				data = yield Util.get_string_from_uri(RadioBrowser.radio_station_tags);
				parser.load_from_data (data);
				root = parser.get_root ();
				items = root.get_array ();
				max_items = (int)items.get_length();
                                Gtk.TreeIter tag_iter;
				for(int a = 0; a < max_items; a++){
					var item = items.get_element(a);
					var item_data = item.get_object ();
                                        tags_model.append(out tag_iter);
                                        tags_model.set(tag_iter, 0, item_data.get_string_member("value"), 1, item_data.get_int_member("stationcount"));
				}

				message("Loaded all category items.");
			}catch (Error e){
				critical("Could not load category items: %s", e.message);
			}
		 }
	}
}
