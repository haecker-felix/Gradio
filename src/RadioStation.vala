namespace Gradio{
	public class RadioStation{

		public string Title = "";
		public string Homepage = "";
		public string Source = "";
		public string Language = "";
		public string ID = "";
		public string Icon = "";
		public string Country = "";
		public string Tags = "";
		public string State = "";
		public string Votes = "";
		public string Codec = "";
		public string Bitrate = "";
		public string DataAddress = "";
		public bool Available = false;

		public signal void data_changed();

		public RadioStation.parse_from_address(string address){
			DataAddress = address;
			json_parse(DataAddress);
		}

		public RadioStation.parse_from_id(int id){
			DataAddress = "http://www.radio-browser.info/webservice/json/stations/byid/" + id.to_string();
			json_parse(DataAddress);
		}

		private void json_parse (string address){
			Json.Parser parser = new Json.Parser ();

			try{
				parser.load_from_data (Util.get_string_from_uri(address));

				var root = parser.get_root ();
				var radio_stations = root.get_array ();

				if(radio_stations.get_length() != 0){
					var radio_station = radio_stations.get_element(0);
					var radio_station_data = radio_station.get_object();

					if(radio_station_data != null){
						Title = radio_station_data.get_string_member ("name");
						Homepage = radio_station_data.get_string_member ("homepage");
						Source = radio_station_data.get_string_member ("url");
						Language = radio_station_data.get_string_member ("language");
						ID = radio_station_data.get_string_member ("id");
						Icon = radio_station_data.get_string_member ("favicon");
						Country = radio_station_data.get_string_member ("country");
						Tags = radio_station_data.get_string_member ("tags");
						State = radio_station_data.get_string_member ("state");
						Votes = radio_station_data.get_string_member ("votes");
						Codec = radio_station_data.get_string_member ("codec");
						Bitrate = radio_station_data.get_string_member ("bitrate");

						if(radio_station_data.get_string_member("lastcheckok") == "1")
							Available = true;
						else
							Available = false;
					}

					// TODO: Support for playlists
					if(Source.contains(".m3u") || Source.contains(".pls"))
						Available = false;
				}

			}catch(GLib.Error e){
				print("Error: " + e.message + "\n");
			}
			data_changed();
		}

		public void vote (){
			Util.get_string_from_uri("http://www.radio-browser.info/webservice/json/vote/" + ID);
			json_parse(DataAddress);
		}
	}
}
