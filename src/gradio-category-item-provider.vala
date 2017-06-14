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

	public class GenericItem : GLib.Object {

		public string text;

		public GenericItem (string t) {
			text = t;
		}
	}

	public class GenericModel : GLib.Object, GLib.ListModel {

		private GLib.GenericArray<GenericItem> items = new GLib.GenericArray<GenericItem> ();

		public GenericModel(){}

		public void clear(){
			uint s = items.length;
			items.remove_range(0, items.length);
	    		this.items_changed (0, s, 0);
		}

  		public GLib.Object? get_item (uint index) {
    			return items.get (index);
  		}

  		public GLib.Type get_item_type () {
    			return typeof (GenericItem);
  		}

 		public uint get_n_items () {
    			return items.length;
  		}

	  	public void add_item(GenericItem item) {
			items.add (item);
			this.items_changed (items.length-1, 0, 1);
	  	}

		public void remove_item (GenericItem item) {
			int pos = 0;
			for (int i = 0; i < items.length; i ++) {
        				GenericItem fitem = items.get (i);
        				if (fitem.text == item.text) {
        					pos = i;
        					break;
        				}
			}

			items.remove_index (pos);
			items_changed (pos, 1, 0);
	  	}
	}


	public class CategoryItemProvider{

		public static GenericModel categories_model;

		public static GenericModel languages_model;
		public static GenericModel countries_model;
		public static GenericModel codecs_model;
		public static GenericModel states_model;
		public static GenericModel tags_model;

		public signal void loaded();
		private signal void partial();
		public bool is_ready = false;

		public CategoryItemProvider(){
			categories_model = new GenericModel();
			GenericItem languagues_item = new GenericItem("Languages");
			categories_model.add_item(languagues_item);
			GenericItem countries_item = new GenericItem("Countries");
			categories_model.add_item(countries_item);
			GenericItem codecs_item = new GenericItem("Codecs");
			categories_model.add_item(codecs_item);
			GenericItem states_item = new GenericItem("States");
			categories_model.add_item(states_item);

			languages_model = new GenericModel();
			countries_model = new GenericModel();
			codecs_model = new GenericModel();
			states_model = new GenericModel();
			tags_model = new GenericModel();

			partial.connect(partial_loaded);

			load_lists.begin();
		}

		private void partial_loaded(){
			if(languages_model.get_n_items() != 0 &&
				countries_model.get_n_items() != 0 &&
				codecs_model.get_n_items() != 0 &&
				states_model.get_n_items() != 0 &&
				tags_model.get_n_items() != 0){

				is_ready = true;
				loaded();
				message("Loaded category items!");
			}
		}

		private async void load_lists (){
        		SourceFunc callback = load_lists.callback;

			message("Load category items...");

			ThreadFunc<void*> run = () => {
				Json.Parser parser = new Json.Parser ();
				string data = "";

				// Languages
				Util.get_string_from_uri.begin(RadioBrowser.radio_station_languages, (obj, res) => {
					data = Util.get_string_from_uri.end(res);

					if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var languages = root.get_array ();
						int max_items = (int)languages.get_length();
						for(int a = 0; a < max_items; a++){
							var language = languages.get_element(a);
							var language_data = language.get_object ();

							GenericItem item = new GenericItem(language_data.get_string_member("value"));
							languages_model.add_item(item);
						}
					}
					partial();
				});

				// Codecs
				Util.get_string_from_uri.begin(RadioBrowser.radio_station_codecs, (obj, res) => {
					data = Util.get_string_from_uri.end(res);

					if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var codecs = root.get_array ();
						int max_items = (int)codecs.get_length();
						for(int a = 0; a < max_items; a++){
							var codec = codecs.get_element(a);
							var codec_data = codec.get_object ();

							GenericItem item = new GenericItem(codec_data.get_string_member("value"));
							codecs_model.add_item(item);
						}
					}
					partial();
				});

				// Countries
				Util.get_string_from_uri.begin(RadioBrowser.radio_station_countries, (obj, res) => {
					data = Util.get_string_from_uri.end(res);

					if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var countries = root.get_array ();
						int max_items = (int)countries.get_length();
						for(int a = 0; a < max_items; a++){
							var country = countries.get_element(a);
							var country_data = country.get_object ();

							GenericItem item = new GenericItem(country_data.get_string_member("value"));
							countries_model.add_item(item);
						}
					}
					partial();
				});

				// States
				Util.get_string_from_uri.begin(RadioBrowser.radio_station_states, (obj, res) => {
					data = Util.get_string_from_uri.end(res);

						if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var states = root.get_array ();
						int max_items = (int)states.get_length();
						for(int a = 0; a < max_items; a++){
							var state = states.get_element(a);
							var state_data = state.get_object ();

							GenericItem item = new GenericItem(state_data.get_string_member("value"));
							states_model.add_item(item);
						}
					}
					partial();
				});

				// Tags
				Util.get_string_from_uri.begin(RadioBrowser.radio_station_tags, (obj, res) => {
					data = Util.get_string_from_uri.end(res);

					if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var tags = root.get_array ();
						int max_items = (int)tags.get_length();
						for(int a = 0; a < max_items; a++){
							var tag = tags.get_element(a);
							var tag_data = tag.get_object ();

							GenericItem item = new GenericItem(tag_data.get_string_member("value"));
							tags_model.add_item(item);
						}
					}
					partial();
				});

				Idle.add((owned) callback);
				Thread.exit (1.to_pointer ());
				return null;
			};

			new Thread<void*> ("load_list_thread", run);
			yield;
        	}

	}
}
