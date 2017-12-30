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
        private const string radio_browser = "https://www.radio-browser.info/webservice/json";

		public const string radio_stations_by_name = radio_browser + "/stations/byname/";
		public const string radio_stations_by_codec = radio_browser + "/stations/bycodec/";
		public const string radio_stations_by_country = radio_browser + "/stations/bycountry/";
		public const string radio_stations_by_state = radio_browser + "/stations/bystate/";
		public const string radio_stations_by_language = radio_browser + "/stations/bylanguage/";
		public const string radio_stations_by_tag = radio_browser + "/stations/bytag/";
		public const string radio_stations_by_id = radio_browser + "/stations/byid/";

		public const string radio_station_vote = radio_browser + "/vote/";
		public const string radio_station_stream_url = "https://www.radio-browser.info/webservice/v2/json/url/";
                public const string radio_station_search = radio_browser + "/stations/search";
		public const string radio_station_languages = radio_browser + "/languages";
		public const string radio_station_countries = radio_browser + "/countries";
		public const string radio_station_codecs = radio_browser + "/codecs";
		public const string radio_station_states = radio_browser + "/states";
		public const string radio_station_tags = radio_browser + "/tags";

		public static string most_votes(int count){
			return radio_browser + "/stations/topvote/" + count.to_string();
		}

		public static string recently_clicked(int count){
			return radio_browser + "/stations/lastclick/" + count.to_string();
		}

		public static string most_clicks(int count){
			return radio_browser + "/stations/topclick/" + count.to_string();
		}
	}


}
