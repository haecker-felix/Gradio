public class RadioStation{

	public string Title;
	public string Homepage;
	public string Source;
	public string Language;
	public string ID;
	public string Icon;
	public string Country;

	public RadioStation.parse_from_address(string address){
		json_parse(address);

	}

	public RadioStation.parse_from_id(int id){
		json_parse("http://www.radio-browser.info/webservice/json/stations/byid/" + id.to_string());
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
				}
			}

		}catch(GLib.Error e){
			print("Error: " + e.message + "\n");
		}

	}
}


