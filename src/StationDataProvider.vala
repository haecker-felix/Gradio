using Gee;
using Gtk;

namespace Gradio{

	public class StationDataProvider{
		// API urls
		public static const string radio_stations_most_votes = "http://www.radio-browser.info/webservice/json/stations/topvote";
		public static const string radio_stations_recently_clicked = "http://www.radio-browser.info/webservice/json/stations/lastclick";
		public static const string radio_stations_recently_changed = "http://www.radio-browser.info/webservice/json/stations/lastchange";
		public static const string radio_stations_by_name = "http://www.radio-browser.info/webservice/json/stations/byname/";
		public static const string radio_stations_by_codec = "http://www.radio-browser.info/webservice/json/stations/bycodec/";
		public static const string radio_stations_by_country = "http://www.radio-browser.info/webservice/json/stations/bycountry/";
		public static const string radio_stations_by_state = "http://www.radio-browser.info/webservice/json/stations/bystate/";
		public static const string radio_stations_by_language = "http://www.radio-browser.info/webservice/json/stations/bylanguage/";
		public static const string radio_stations_by_tag = "http://www.radio-browser.info/webservice/json/stations/bytag/";
		public static const string radio_stations_by_id = "http://www.radio-browser.info/webservice/json/stations/byid/";
		public static const string radio_station_vote = "http://www.radio-browser.info/webservice/json/vote/";
		public static const string radio_station_stream_url = "http://www.radio-browser.info/webservice/v2/json/url/";
		public static const string radio_station_edit = "http://www.radio-browser.info/webservice/json/edit/";
		public static const string radio_station_languages = "http://www.radio-browser.info/webservice/json/languages";


		// Aviable lists
		public static GLib.List<string> languages_list;

		// for the search thread
		private bool _isWorking = false;
		public signal void status_changed();
		public bool isWorking { get { return _isWorking;} set { _isWorking = value; status_changed();}}


		// Returns the playable url for the station
		public async string get_stream_address (string ID){
			SourceFunc callback = get_stream_address.callback;
			string url = "";

			ThreadFunc<void*> run = () => {
				string tmp = "";				
				try{			
					Json.Parser parser = new Json.Parser ();
					parser.load_from_data (Util.get_string_from_uri(radio_station_stream_url + ID ));
					var root = parser.get_root ();			

					if(root != null){
						var radio_station_data = root.get_object ();		
						if(radio_station_data.get_string_member("ok") ==  "true"){
							tmp = radio_station_data.get_string_member("url");
						}
					}
				}catch(GLib.Error e){
					warning(e.message);
				}
				
				url = tmp;

				Idle.add((owned) callback);
				Thread.exit (1.to_pointer ());
				return null;
			};

			new Thread<void*> ("get_url_thread", run);

			yield;

			return url;
		}

		// Edit a radiostation
		public async bool edit_radio_station(RadioStation edited){

			return false;
		}

		// Increase the vote count for the station by one.
		public int vote_for_station(RadioStation station){
			Json.Parser parser = new Json.Parser ();

			try{
				parser.load_from_data (Util.get_string_from_uri(radio_station_vote + station.ID ));
				var root = parser.get_root ();

				if(root != null){
					var radio_station_data = root.get_object ();
					if(radio_station_data.get_string_member("ok") ==  "true"){
						return (int.parse(station.Votes)+1);
					}
				}

				return int.parse(station.Votes);
			}catch(GLib.Error e){
				return int.parse(station.Votes);
			}

		}


		// Get the station data from ID
		public RadioStation parse_station_data_from_id (int id){
			Json.Parser parser = new Json.Parser ();
			RadioStation new_station = null;

			string data = Util.get_string_from_uri(radio_stations_by_id + id.to_string());
			try{
				if(data != ""){
					parser.load_from_data (data);
					var root = parser.get_root ();
					var radio_stations = root.get_array ();

					if(radio_stations.get_length() == 0){
						return null;
					}

					var radio_station = radio_stations.get_element(0);
					var radio_station_data = radio_station.get_object ();

					new_station = parse_station_data_from_json(radio_station_data);
				}else{
					return null;
				}
			}catch (Error e){
				error("Parser: " + e.message);
			}

			return new_station;
		}


		// Parse the station data and return a station object
		private RadioStation parse_station_data_from_json (Json.Object radio_station_data){
			string title = radio_station_data.get_string_member("name");
			string homepage = radio_station_data.get_string_member("homepage");
			string language = radio_station_data.get_string_member("language");
			string id = radio_station_data.get_string_member("id");
			string icon = radio_station_data.get_string_member("favicon");
			string country = radio_station_data.get_string_member("country");
			string tags = radio_station_data.get_string_member("tags");
			string state = radio_station_data.get_string_member("state");
			string votes = radio_station_data.get_string_member("votes");
			string codec = radio_station_data.get_string_member("codec");
			string bitrate = radio_station_data.get_string_member("bitrate");
			bool broken;
						
			if(radio_station_data.get_string_member("lastcheckok") == "1")
				broken = false;
			else
				broken = true;

			RadioStation station = new RadioStation(title, homepage, language, id, icon, country, tags, state, votes, codec, bitrate, broken);
			return station;	
		}


		// Handle several stations and return them as a map 
		public async HashMap<int,RadioStation> get_radio_stations(string address, int max_results) throws ThreadError{
			SourceFunc callback = get_radio_stations.callback;
			HashMap<int,RadioStation> output = new HashMap<int,RadioStation>();

			isWorking = true;
			ThreadFunc<void*> run = () => {
				try{
		   			HashMap<int,RadioStation> results = new HashMap<int,RadioStation>();
					string data = Util.get_string_from_uri(address);
					Json.Parser parser = new Json.Parser ();

					if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var radio_stations = root.get_array ();

						int max_items = (int)radio_stations.get_length();
						if(max_items < max_results)
							max_results = max_items;

						for(int a = 0; a < max_results; a++){
							var radio_station = radio_stations.get_element(a);
							var radio_station_data = radio_station.get_object ();
						
							var station = parse_station_data_from_json(radio_station_data);

							results[int.parse(station.ID)] = station;
						}

						output = results;
					}else{
						output = null;
					}
					
				}catch(GLib.Error e){
					warning(e.message);
				}
				
				Idle.add((owned) callback);
				Thread.exit (1.to_pointer ());
				return null;
			};

			new Thread<void*> ("search_thread", run);

			yield;
			isWorking = false;
           		return output;
        	}

        	public async void load_lists (){
        		SourceFunc callback = load_lists.callback;

			isWorking = true;
			ThreadFunc<void*> run = () => {
				languages_list = null;
				languages_list = new GLib.List<string>();

				try{
					Json.Parser parser = new Json.Parser ();
					string data;

					// Languages
					data = Util.get_string_from_uri(radio_station_languages);
					if(data != ""){
						parser.load_from_data (data);
						var root = parser.get_root ();
						var languages = root.get_array ();
						int max_items = (int)languages.get_length();
						for(int a = 0; a < max_items; a++){
							var language = languages.get_element(a);
							var language_data = language.get_object ();
							languages_list.append(language_data.get_string_member("value"));
						}
					}

				}catch(GLib.Error e){
					warning(e.message);
				}
				Idle.add((owned) callback);
				Thread.exit (1.to_pointer ());
				return null;
			};

			new Thread<void*> ("load_list_thread", run);

			yield;
			isWorking = false;
        	}
	}
}

