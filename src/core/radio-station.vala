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
	public class RadioStation{

		public string Title = "";
		public string Homepage = "";
		public string Language = "";
		public int ID = 0;
		public string Icon = "";
		public string Country = "";
		public string Tags = "";
		public string State = "";
		public string Votes = "";
		public string Codec = "";
		public string Bitrate = "";
		public bool Broken = true;

		public bool is_playing = false;
		public signal void stopped();
		public signal void played();

		public bool is_in_library = false;
		public signal void added_to_library();
		public signal void removed_from_library();

		public RadioStation(	string title = "",
					string homepage = "",
					string language = "",
					string id = "",
					string icon = "",
					string country = "",
					string tags = "",
					string state = "",
					string votes = "",
					string codec = "",
					string bitrate = "",
					bool broken = false){

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

		private void connect_signals(){
			App.player.played.connect(() => {
				stopped();
				if(App.player.current_station != null && App.player.current_station.ID == ID){
					is_playing = true;
					played();
				}
			});

			App.player.stopped.connect(() => {
				if(App.player.current_station != null && App.player.current_station.ID == ID){
					is_playing = false;
					stopped();
				}
			});
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


		public bool vote (){
			Json.Parser parser = new Json.Parser ();

			try{
				parser.load_from_data (Util.get_string_from_uri(RadioBrowser.radio_station_vote + ID.to_string() ));
				var root = parser.get_root ();

				if(root != null){
					var radio_station_data = root.get_object ();
					if(radio_station_data.get_string_member("ok") ==  "true"){
						int v = int.parse(Votes);
						v++;
						Votes=v.to_string();
						return true;
					}
				}
			}catch(GLib.Error e){
				warning(e.message);
			}

			return false;
		}

		//copy data from a other station
		public void set_from_station(RadioStation s){
			Title = s.Title;
			Homepage = s.Homepage;
			Language = s.Language;
			ID = s.ID;
			Icon = s.Icon;
			Country = s.Country;
			Tags = s.Tags;
			State = s.State;
			Votes = s.Votes;
			Codec = s.Codec;
			Bitrate = s.Bitrate;
			Broken = s.Broken;

			if(App.player.is_playing_station(this))
				is_playing = true;

			if(Broken)
				Title = "[BROKEN] " + Title;
		}
	}
}
