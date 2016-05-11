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
		GLib.Cancellable cancellable;

		private bool _isWorking = false;
		public signal void status_changed();

		//bullshit?
		public bool isWorking {
			get { return _isWorking; status_changed();}
			set { _isWorking = value; status_changed();}
		}

		public RadioStationsProvider (ref GradioApp a) {
			app = a;
			cancellable = new GLib.Cancellable ();

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

		public async ArrayList<RadioStation> search_radio_stations(string search, Search type) throws ThreadError{
			SourceFunc callback = search_radio_stations.callback;

			ArrayList<RadioStation> output = new ArrayList<RadioStation>();


			string search_type = "byname/";
			// soon
			/*
			switch(type){
				case type.BY_NAME: search_type = "";
			}
			*/

			// alten thread beenden
			while(isWorking){
				cancellable.cancel ();
			}
			cancellable.reset ();

			new GLib.Thread<void*> (null, () => {
				isWorking = true;
				try{
					cancellable.set_error_if_cancelled ();

					print("Info: SearchProvider: Search thread started.\n");

		   			ArrayList<RadioStation> results = new ArrayList<RadioStation>();
					Json.Parser parser = new Json.Parser ();

					cancellable.set_error_if_cancelled ();

					parser.load_from_data (Util.get_string_from_uri("http://www.radio-browser.info/webservice/json/stations/"+search_type+Util.optimize_string(search)));
					var root = parser.get_root ();
					var radio_stations = root.get_array ();

					cancellable.set_error_if_cancelled ();

					foreach(var radio_station in radio_stations.get_elements()){
						cancellable.set_error_if_cancelled ();
						var radio_station_data = radio_station.get_object ();
						RadioStation station = new RadioStation.parse_from_id(int.parse(radio_station_data.get_string_member("id")));
						cancellable.set_error_if_cancelled ();
						results.add(station);
					}

					output = results;
					print("Info: SearchProvider: Fetched results!\n");
				}catch(GLib.Error e){
					print("Info: SearchProvider: " + e.message + "\n");
				}

				isWorking = false;
				Idle.add((owned) callback);
				return null;
			});

			yield;
           		return output;
        	}
	}
}

