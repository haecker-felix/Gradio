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

	public class RadioBrowser{
		public const string radio_stations_by_name = "http://www.radio-browser.info/webservice/json/stations/byname/";
		public const string radio_stations_by_codec = "http://www.radio-browser.info/webservice/json/stations/bycodec/";
		public const string radio_stations_by_country = "http://www.radio-browser.info/webservice/json/stations/bycountry/";
		public const string radio_stations_by_state = "http://www.radio-browser.info/webservice/json/stations/bystate/";
		public const string radio_stations_by_language = "http://www.radio-browser.info/webservice/json/stations/bylanguage/";
		public const string radio_stations_by_tag = "http://www.radio-browser.info/webservice/json/stations/bytag/";
		public const string radio_stations_by_id = "http://www.radio-browser.info/webservice/json/stations/byid/";

		public const string radio_station_vote = "http://www.radio-browser.info/webservice/json/vote/";
		public const string radio_station_stream_url = "http://www.radio-browser.info/webservice/v2/json/url/";

		public const string radio_station_languages = "http://www.radio-browser.info/webservice/json/languages";
		public const string radio_station_countries = "http://www.radio-browser.info/webservice/json/countries";
		public const string radio_station_codecs = "http://www.radio-browser.info/webservice/json/codecs";
		public const string radio_station_states = "http://www.radio-browser.info/webservice/json/states";
		public const string radio_station_tags = "http://www.radio-browser.info/webservice/json/tags";

		public static string most_votes(int count){
			return "http://www.radio-browser.info/webservice/json/stations/topvote/" + count.to_string();
		}

		public static string recently_clicked(int count){
			return "http://www.radio-browser.info/webservice/json/stations/lastclick/" + count.to_string();
		}

		public static string most_clicks(int count){
			return "http://www.radio-browser.info/webservice/json/stations/topclick/" + count.to_string();
		}
	}


}
