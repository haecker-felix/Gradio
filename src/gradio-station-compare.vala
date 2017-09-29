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

	public enum Compare {
		VOTES,
		NAME,
		LANGUAGE,
		COUNTRY,
		BITRATE,
		CLICKS,
		STATE,
		DATE
	}

	public class StationCompare{
		public CompareDataFunc<Gd.MainBoxItem> compare = (a, b) => {
			int result = 0;
			RadioStation stationA;
			RadioStation stationB;

			if(Util.is_collection_item(int.parse(a.id.to_string())) || Util.is_collection_item(int.parse(b.id.to_string()))){
				return result;
			}else{
				stationA = (RadioStation)a;
				stationB = (RadioStation)b;
			}

			switch(App.settings.station_sorting){
				case Compare.VOTES: {
					int avotes = int.parse(stationA.votes);
					int bvotes = int.parse(stationB.votes);

					if(avotes > bvotes) result = 1;
					if(avotes == bvotes) result = 0;
					if(avotes < bvotes) result = -1;
					break;
				}
				case Compare.NAME: {
					result = (strcmp(stationA.title, stationB.title)*-1);
					break;
				}
				case Compare.LANGUAGE: {
					result = (strcmp(stationA.language, stationB.language) * -1);
					break;
				}
				case Compare.COUNTRY: {
					result = (strcmp(stationA.country, stationB.country) * -1);
					break;
				}
				case Compare.BITRATE: {
					int abitrate = int.parse(stationA.bitrate);
					int bbitrate = int.parse(stationB.bitrate);

					if(abitrate > bbitrate) result = 1;
					if(abitrate == bbitrate) result = 0;
					if(abitrate < bbitrate) result = -1;
					break;
				}
				case Compare.CLICKS: {
					int aclicks = int.parse(stationA.clickcount);
					int bclicks = int.parse(stationB.clickcount);

					if(aclicks > bclicks) result = 1;
					if(aclicks == bclicks) result = 0;
					if(aclicks < bclicks) result = -1;
					break;
				}
				case Compare.STATE: {
					result = (strcmp(stationA.state, stationB.state) * -1);
					break;
				}
				case Compare.DATE: {
					result = (strcmp(stationA.clicktimestamp, stationB.clicktimestamp)* -1);
					break;
				}
			}

			if(!App.settings.sort_ascending){
				result = result * -1;
			}

			return result;
		};
	}
}
