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
		private string _clickcount;
		private string _clicktimestamp;
		private string _icon_address;
		private bool _is_broken;
		private bool _pulse;
		private int64 _mtime;
		private Cairo.Surface _icon;
		private Thumbnail _thumbnail;
		private string _primary_text;
		private string _secondary_text;

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

		public string clickcount {
			get{return _clickcount;}
			set{_clickcount = value;}
		}

		public string clicktimestamp {
			get{return _clicktimestamp;}
			set{_clicktimestamp = value;}
		}

		public string uri {
			get{return _id;}
		}

		public string primary_text {
			get{
				if(_title.length > 28){
					_primary_text = _title.substring(0, 25);
					_primary_text = _primary_text + "...";
				}else{
					_primary_text = _title;
				}

			return _primary_text;}
		}

		public string secondary_text {
			get{return _secondary_text;}
		}

		public string icon_address {
			get{return _icon_address;}
			set{_icon_address = value;}
		}

		public bool is_broken {
			get{return _is_broken;}
			set{_is_broken = value;}
		}

		public bool pulse {
			get{return _pulse;}
		}

		public int64 mtime {
			get{return _mtime;}
		}

		public Cairo.Surface icon {
			get{
				if(_thumbnail == null){
					_thumbnail = new Thumbnail.for_station(App.settings.icon_zoom, this);
					_thumbnail.updated.connect(() => {
						_icon = _thumbnail.surface;
						notify_property("icon");
					});
					_thumbnail.show_empty_box();
					return _icon;
				}
				return _icon;
			}
		}

		public RadioStation.from_json_data(Json.Object radio_station_data){
			load_data_from_json(radio_station_data);
			update_secondary_text();
			connect_signals();
		}

		private void connect_signals(){
			App.settings.notify["station-sorting"].connect(update_secondary_text);
			App.settings.notify["icon-zoom"].connect(update_thumbnail);
		}

		private void update_secondary_text(){
			switch(App.settings.station_sorting){
				case Compare.NAME: _secondary_text = ""; break;
				case Compare.DATE: _secondary_text = clicktimestamp; break;
				case Compare.STATE: _secondary_text = state; break;
				case Compare.VOTES: _secondary_text = votes + " " + _("Votes"); break;
				case Compare.CLICKS: _secondary_text = clickcount + " " + _("Clicks"); break;
				case Compare.COUNTRY: _secondary_text = country; break;
				case Compare.BITRATE: _secondary_text = bitrate + " kBit/s"; break;
				case Compare.LANGUAGE: _secondary_text = language; break;
			}
			notify_property("secondary-text");
		}

		private void update_thumbnail(){
			if(_thumbnail != null && this != null){
				_thumbnail.set_zoom(App.settings.icon_zoom);
			}
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
			_clickcount = radio_station_data.get_string_member("clickcount");
			_clicktimestamp = radio_station_data.get_string_member("clicktimestamp");

			if(radio_station_data.get_string_member("lastcheckok") == "1")
				_is_broken = false;
			else
				_is_broken = true;
		}

		// Returns the playable url for the station
		public async string get_stream_address (){
			SourceFunc callback = get_stream_address.callback;
			string url = "";

			string data = "";

			Util.get_string_from_uri.begin(RadioBrowser.radio_station_stream_url + _id, (obj, res) => {
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

		// Returns the html description metadata
		// Much mess here. Feel free to improve this crap :)
		public async string get_description(){
			SourceFunc callback = get_description.callback;

			string descr = "";
			string html = "";
			string url = _homepage;

			// http://bla.org/da/da/da/da -> http://bla.org
			bool finished = false;
			while(!finished){
				int lastindex = url.last_index_of("/");

				// http://
				if(url.get_char(lastindex-1) != '/'){
					url = url.slice(0, lastindex);
				}else{
					finished = true;
				}
			}


			// download the html
			Util.get_string_from_uri.begin(url, (obj, res) => {
				string result = Util.get_string_from_uri.end(res);

				if(result != null)
					html = result;
				Idle.add((owned) callback);
			});

			yield;

			// search description metadata
			int start_index = html.index_of("<meta name=\"description\" content=\"");
			int end_index = -1;

			// now find the end of the metadata
			if(start_index > -1){
				string desc1 = html.substring(start_index+34);

				// ... "/>
				int e1 = desc1.index_of("\"/>");
				if((e1 > end_index && end_index == -1) || (e1 < end_index && e1 > -1))
					end_index = e1;

				// ... >
				int e2 = desc1.index_of("\">");
				if((e2 > end_index && end_index == -1) || (e2 < end_index && e2 > -1))
					end_index = e2;

				// ... " >
				int e3 = desc1.index_of("\" >");
				if((e3 > end_index && end_index == -1) || (e3 < end_index && e3 > -1))
					end_index = e3;

				// ... " />
				int e4 = desc1.index_of("\" />");
				if((e4 > end_index && end_index == -1) || (e4 < end_index && e4 > -1))
					end_index = e4;

				if(end_index > -1){
					descr = desc1.slice(0,end_index);
				}
			}

			return descr;
		}
	}
}
