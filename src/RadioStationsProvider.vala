using Gee;
using Gtk;

namespace Gradio{

	public enum Search {
		BY_ID,
		BY_NAME,
		BY_NAME_EXACT,
		BY_CODEC,
		BY_COUNTRY,
		BY_COUNTRY_EXACT,
		BY_STATE,
		BY_STATE_EXACT,
		BY_LANGUAGE,
		BY_LANGUAGE_EXACT,
		BY_TAG,
		BY_TAG_EXACT,
	}

	public class RadioStationsProvider{
		GradioApp app;

		private bool _isWorking = false;
		public signal void status_changed();

		public bool isWorking {
			get { return _isWorking;}
			set { _isWorking = value; status_changed();}
		}


		public RadioStationsProvider (ref GradioApp a) {
			app = a;
		}

		public async ArrayList<RadioStation> get_most_clicked_list(){
			return null;
		}

		public async ArrayList<RadioStation> get_most_voted_list(){
			return null;
		}

		public async ArrayList<RadioStation> get_last_played_list(){
			return null;
		}

		public async ArrayList<RadioStation> search_radio_stations(string search, Search type, int max_results) throws ThreadError{
			SourceFunc callback = search_radio_stations.callback;
			ArrayList<RadioStation> output = new ArrayList<RadioStation>();

			string search_type = "byname/";

			isWorking = true;
			ThreadFunc<void*> run = () => {
				try{
					
					message("Search thread started.");
		   			ArrayList<RadioStation> results = new ArrayList<RadioStation>();

					
					Json.Parser parser = new Json.Parser ();

					parser.load_from_data (Util.get_string_from_uri("http://www.radio-browser.info/webservice/json/stations/"+search_type+Util.optimize_string(search)));
					var root = parser.get_root ();
					var radio_stations = root.get_array ();

					int max_items = (int)radio_stations.get_length();
					if(max_items < max_results)
						max_results = max_items;					


					for(int a = 0; a < max_results; a++){
						message(a.to_string());
						var radio_station = radio_stations.get_element(a);
						var radio_station_data = radio_station.get_object ();
						RadioStation station = new RadioStation.parse_from_id(int.parse(radio_station_data.get_string_member("id")));
						results.add(station);
					}
					

					output = results;
					message("Fetched results!");
				}catch(GLib.Error e){
					warning(e.message);
				}
				
				Idle.add((owned) callback);
				Thread.exit (1.to_pointer ());
				return null;
			};

			Thread<void*> search_thread = new Thread<void*> ("search_thread", run);

			yield;
			isWorking = false;
           		return output;
        	}
	}
}

