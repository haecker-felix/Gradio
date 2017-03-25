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
	public class RadioStation : GLib.Object{
		public string Title { get; set; }
		public string Homepage { get; set; }
		public string Language { get; set; }
		public int ID { get; set; }
		public string Icon { get; set; }
		public string Country { get; set; }
		public string Tags { get; set; }
		public string State { get; set; }
		public string Votes { get; set; }
		public string Codec { get; set; }
		public string Bitrate { get; set; }
		public bool Broken { get; set; }

		public bool is_playing = false;
		public signal void stopped();
		public signal void played();

		public signal void added_to_library();
		public signal void removed_from_library();

		public RadioStation(string title = "", string homepage = "", string language = "", string id = "", string icon = "", string country = "", string tags = "", string state = "", string votes = "", string codec = "", string bitrate = "", bool broken = false){
			if(id != ""){
				Title = title;
				Homepage = homepage;
				Language = language;
				ID = int.parse(id);
				Icon = icon;
				Country = country;
				Tags = tags;
				State = state;
				Votes = votes;
				Codec = codec;
				Bitrate = bitrate;
				Broken = broken;

				if(App.player.is_playing_station(this))
					is_playing = true;

				if(Broken)
					Title = "[BROKEN] " + Title;

				connect_signals();
			}
		}

		public RadioStation.from_json_data(Json.Object radio_station_data){
			load_data_from_json(radio_station_data);
			connect_signals();
		}

		~RadioStation(){
			App.player.station_played.disconnect( play_handler );
			App.player.station_stopped.disconnect( stop_handler );
			App.library.added_radio_station.disconnect( added_to_library_handler );
			App.library.removed_radio_station.disconnect( removed_from_library_handler );
		}

		private void connect_signals(){
			App.player.station_played.connect(play_handler);
			App.player.station_stopped.connect(stop_handler);

			App.library.added_radio_station.connect(added_to_library_handler);
			App.library.removed_radio_station.connect(removed_from_library_handler);
		}

		private void load_data_from_json(Json.Object radio_station_data){
			Title = radio_station_data.get_string_member("name");
			Homepage = radio_station_data.get_string_member("homepage");
			Language = radio_station_data.get_string_member("language");
			ID = int.parse(radio_station_data.get_string_member("id"));
			Icon = radio_station_data.get_string_member("favicon");
			Country = radio_station_data.get_string_member("country");
			Tags = radio_station_data.get_string_member("tags");
			State = radio_station_data.get_string_member("state");
			Votes = radio_station_data.get_string_member("votes");
			Codec = radio_station_data.get_string_member("codec");
			Bitrate = radio_station_data.get_string_member("bitrate");

			if(radio_station_data.get_string_member("lastcheckok") == "1")
				Broken = false;
		}

		private void stop_handler(){
			if(Title != null){
				if(App.player.current_station.ID == ID){
					is_playing = false;
					stopped();
				}
			}else{
				warning("Catched crash of Gradio.");
			}

		}

		private void play_handler(){
			if(Title != null){
				if(App.player.current_station.ID == ID){
					is_playing = true;
					played();
				}else{
					is_playing = false;
					stopped();
				}
			}else{
				warning("Catched crash of Gradio.");
			}
		}

		private void added_to_library_handler(RadioStation s){
			if(Title != null){
				if(s.ID == ID){
					added_to_library();

				}
			}else{
				warning("Catched crash of Gradio.");
			}
		}

		private void removed_from_library_handler(RadioStation s){
			if(Title != null){
				if(s.ID == ID){
					removed_from_library();
				}
			}else{
				warning("Catched crash of Gradio.");
			}
		}

		// Returns the playable url for the station
		public async string get_stream_address (string ID){
			SourceFunc callback = get_stream_address.callback;
			string url = "";

			string data = "";

			Util.get_string_from_uri.begin(RadioBrowser.radio_station_stream_url + ID, (obj, res) => {
				string result = Util.get_string_from_uri.end(res);

				if(result != null)
					data = result;
				Idle.add((owned) callback);
			});

			yield;

			try{
				Json.Parser parser = new Json.Parser ();

				parser.load_from_data (data);
				var root = parser.get_root ();
				if(root != null){
					var radio_station_data = root.get_object ();
					if(radio_station_data.get_string_member("ok") ==  "true"){
						url = radio_station_data.get_string_member("url");
					}
				}


			}catch(GLib.Error e){
				warning(e.message);
			}

			message("returning: " + url);
			return url;
		}


		public bool vote (){
			Json.Parser parser = new Json.Parser ();
			bool vote = false;

			Util.get_string_from_uri.begin(RadioBrowser.radio_station_vote + ID.to_string(), (obj, res) => {
				string data = Util.get_string_from_uri.end(res);

				try{
					parser.load_from_data (data);

					var root = parser.get_root ();

					if(root != null){
						var radio_station_data = root.get_object ();
						if(radio_station_data.get_string_member("ok") ==  "true"){
							int v = int.parse(Votes);
							v++;
							Votes=v.to_string();
							vote = true;
						}
					}
				}catch(Error e){
					critical("Could not vote station: " + e.message);
				}

			});
			return vote;
		}
	}
}
