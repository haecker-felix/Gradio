namespace Gradio{
	public class RadioStation{

		public string Title = "";
		public string Homepage = "";
		public string Language = "";
		public string ID = "";
		public string Icon = "";
		public string Country = "";
		public string Tags = "";
		public string State = "";
		public string Votes = "";
		public string Codec = "";
		public string Bitrate = "";
		public bool Broken = true;

		public signal void data_changed();

		public RadioStation(string title, string homepage, string language, string id, string icon, string country, string tags, string state, string votes, string codec, string bitrate, bool broken){
			Title = title;
			Homepage = homepage;
			Language = language;
			ID = id;
			Icon = icon;
			Country = country;
			Tags = tags;
			State = state;
			Votes = votes;
			Codec = codec;
			Bitrate = bitrate;
			Broken = broken;

			if(Broken)
				Title = "[BROKEN] " + Title;
		}

		// Returns the playable url for the station
		public async string get_stream_address (string ID){
			SourceFunc callback = get_stream_address.callback;
			string url = "";

			ThreadFunc<void*> run = () => {
				string tmp = "";
				try{
					Json.Parser parser = new Json.Parser ();
					parser.load_from_data (Util.get_string_from_uri(RadioBrowser.radio_station_stream_url + ID ));
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


		public void vote (){
			Json.Parser parser = new Json.Parser ();

			try{
				parser.load_from_data (Util.get_string_from_uri(RadioBrowser.radio_station_vote + ID ));
				var root = parser.get_root ();

				if(root != null){
					var radio_station_data = root.get_object ();
					if(radio_station_data.get_string_member("ok") ==  "true"){
						int v = int.parse(Votes);
						v++;
						Votes=v.to_string();
					}
				}
			}catch(GLib.Error e){
				warning(e.message);
			}

			data_changed();
		}
	}
}
