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

using Gdk;

namespace Gradio{
	public class RadioStation : GLib.Object, Gd.MainBoxItem{
		private string _title;
		private string _homepage;
		private string _language;
		private string _id;
		private string _country;
		private string _tags;
		private string _state;
		private string _votes;
		private string _codec;
		private string _bitrate;
		private string _uri;
		private string _icon_address;
		private bool _is_broken;
		private bool _is_playing;
		private bool _pulse;
		private int64 _mtime;
		private Cairo.Surface _icon;
		private Pixbuf _pixbuf;

		public string title {
			get{return _title;}
			set{_title = value;}
		}

		public string homepage {
			get{return _homepage;}
			set{_homepage = value;}
		}

		public string language {
			get{return _language;}
			set{_language = value;}
		}

		public string id {
			get{return _id;}
		}
		public string country {
			get{return _country;}
			set{_country = value;}
		}

		public string tags {
			get{return _tags;}
			set{_tags = value;}
		}

		public string state {
			get{return _state;}
			set{_state = value;}
		}

		public string votes {
			get{return _votes;}
			set{_votes = value;}
		}

		public string codec {
			get{return _codec;}
			set{_codec = value;}
		}

		public string bitrate {
			get{return _bitrate;}
			set{_bitrate = value;}
		}

		public string uri {
			get{return _uri;}
		}

		public string primary_text {
			get{return _title;}
		}

		public string secondary_text {
			get{return _country;}
		}

		public string icon_address {
			get{return _icon_address;}
			set{_icon_address = value;}
		}

		public bool is_broken {
			get{return _is_broken;}
			set{_is_broken = value;}
		}

		public bool is_playing {
			get{return _is_playing;}
			set{_is_playing = value;}
		}

		public bool pulse {
			get{return _pulse;}
		}

		public int64 mtime {
			get{return _mtime;}
		}

		public Cairo.Surface icon {
			get{
				message("request icon");
				if(_pixbuf == null){
					message ("pixbuf is null -> downloading");
					download_icon.begin();

					_pixbuf = new Pixbuf (Gdk.Colorspace.RGB, true, 8, 192, 192);
					Cairo.Surface surface = Gdk.cairo_surface_create_from_pixbuf(_pixbuf, 1, null);

					_icon = surface;
					return _icon;
				}else{
					message ("returning the local cached image");
					Util.optiscale(ref _pixbuf, 192);
					Cairo.Surface surface = Gdk.cairo_surface_create_from_pixbuf(_pixbuf, 1, null);
					_icon = surface;

					return _icon;
				}
			}
		}

		public signal void stopped();
		public signal void played();

		public signal void added_to_library();
		public signal void removed_from_library();

		public RadioStation(string title = "", string homepage = "", string language = "", string id = "", string icon = "", string country = "", string tags = "", string state = "", string votes = "", string codec = "", string bitrate = "", bool is_broken = false){
			if(id != ""){
				_title = title;
				_homepage = homepage;
				_language = language;
				_id = id;
				_icon_address = icon;
				_country = country;
				_tags = tags;
				_state = state;
				_votes = votes;
				_codec = codec;
				_bitrate = bitrate;
				_is_broken = is_broken;

				if(App.player.is_playing_station(this))
					is_playing = true;

				if(_is_broken)
					_title = "[BROKEN] " + _title;

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
			_title = radio_station_data.get_string_member("name");
			_homepage = radio_station_data.get_string_member("homepage");
			_language = radio_station_data.get_string_member("language");
			_id = radio_station_data.get_string_member("id");
			_icon_address = radio_station_data.get_string_member("favicon");
			_country = radio_station_data.get_string_member("country");
			_tags = radio_station_data.get_string_member("tags");
			_state = radio_station_data.get_string_member("state");
			_votes = radio_station_data.get_string_member("votes");
			_codec = radio_station_data.get_string_member("codec");
			_bitrate = radio_station_data.get_string_member("bitrate");

			if(radio_station_data.get_string_member("lastcheckok") == "1")
				_is_broken = false;
		}

		private async void download_icon(){
			var session = new Soup.SessionAsync ();
			session.user_agent = "gradio/"+ Config.VERSION;
			var message = new Soup.Message ("GET", _icon_address);
			var loader = new Gdk.PixbufLoader();

			session.queue_message (message, (session, msg) => {
				if(message.response_body.data != null){
					loader.write(message.response_body.data);
					loader.close();
					_pixbuf = loader.get_pixbuf();

					notify_property("icon");
				}
		    	});
			yield;
		}

		private void stop_handler(){
			if(_title != null){
				if(App.player.current_station.id == _id){
					_is_playing = false;
					stopped();
				}
			}else{
				warning("Catched crash of Gradio.");
			}

		}

		private void play_handler(){
			if(_title != null){
				if(App.player.current_station.id == _id){
					_is_playing = true;
					played();
				}else{
					_is_playing = false;
					stopped();
				}
			}else{
				warning("Catched crash of Gradio.");
			}
		}

		private void added_to_library_handler(RadioStation s){
			if(_title != null){
				if(s.id == _id){
					added_to_library();

				}
			}else{
				warning("Catched crash of Gradio.");
			}
		}

		private void removed_from_library_handler(RadioStation s){
			if(_title != null){
				if(s.id == _id){
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

			Util.get_string_from_uri.begin(RadioBrowser.radio_station_vote + id, (obj, res) => {
				string data = Util.get_string_from_uri.end(res);

				try{
					parser.load_from_data (data);

					var root = parser.get_root ();

					if(root != null){
						var radio_station_data = root.get_object ();
						if(radio_station_data.get_string_member("ok") ==  "true"){
							int v = int.parse(votes);
							v++;
							_votes=v.to_string();
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
