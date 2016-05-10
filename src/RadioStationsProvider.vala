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

		private async ArrayList<RadioStation> process_data(string data_url){
			SourceFunc callback = process_data.callback;
			ArrayList<RadioStation> output = new ArrayList<RadioStation>();

			// stop old thread
			while(isWorking)
				cancellable.cancel ();

			cancellable.reset ();

			// start new thread

			ThreadFunc<void*> run = () => {
				print("new thread\n");
				isWorking = true;
				try{
					cancellable.set_error_if_cancelled ();

		   			ArrayList<RadioStation> results = new ArrayList<RadioStation>();
					Json.Parser parser = new Json.Parser ();

					cancellable.set_error_if_cancelled ();

					parser.load_from_data (Util.get_string_from_uri(data_url));
					var root = parser.get_root ();
					var radio_stations = root.get_array ();

					cancellable.set_error_if_cancelled ();

					foreach(var radio_station in radio_stations.get_elements()){
						print("ehm...\n");
						cancellable.set_error_if_cancelled ();
						var radio_station_data = radio_station.get_object ();
						RadioStation station = new RadioStation.parse_from_id(int.parse(radio_station_data.get_string_member("id")));
						results.add(station);
					}

					output = results;
				}catch(GLib.Error e){
					print("Info: RadioStationsProvider: " + e.message + "\n");
				}

				isWorking = false;
				print("thread stopped...\n");
				Idle.add((owned) callback);
				return null;
			};

			Thread.create<void*>(run, false);

			yield;

			print("method stopped...\n");

           		return output;
		}

		public async ArrayList<RadioStation> search_radio_stations(string search, Search type) throws ThreadError{
			ArrayList<RadioStation> output = new ArrayList<RadioStation>();

			// search type
			string search_type = "byname/";
			/*
			switch(type){
				case type.BY_NAME: search_type = "byname/"; break;
				case type.BY_COUNTRY: search_type = "bycountry/"; break;
				case type.BY_LANGUAGE: search_type = "bylanguage/"; break;
				case type.BY_TAG: search_type = "bytag/"; break;
			}
			*/


			process_data.begin("http://www.radio-browser.info/webservice/json/stations/" + search_type+Util.optimize_string(search), (obj, res) => {
		        		print("waiting for output...");
		        		output = process_data.end(res);
		        		print("got output...\n");
        		});

			print("returning output search_radio_stations\n");
			return output;
        	}
	}
}

