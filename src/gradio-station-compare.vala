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
		public CompareFunc<RadioStation> compare = (a, b) => {
			int result = 0;

			switch(Settings.station_sorting){
				case Compare.VOTES: {
					int avotes = int.parse(a.votes);
					int bvotes = int.parse(b.votes);

					if(avotes > bvotes) return 1;
					if(avotes == bvotes) return 0;
					if(avotes < bvotes) return -1;
					break;
				}
				case Compare.NAME: {
					result = strcmp(a.title, b.title);
					break;
				}
				case Compare.LANGUAGE: {
					result = strcmp(a.language, b.language);
					break;
				}
				case Compare.COUNTRY: {
					result = strcmp(a.country, b.country);
					break;
				}
				case Compare.BITRATE: {
					int abitrate = int.parse(a.bitrate);
					int bbitrate = int.parse(b.bitrate);

					if(abitrate > bbitrate) return 1;
					if(abitrate == bbitrate) return 0;
					if(abitrate < bbitrate) return -1;
					break;
				}
				case Compare.CLICKS: {
					int aclicks = int.parse(a.clickcount);
					int bclicks = int.parse(b.clickcount);

					if(aclicks > bclicks) return 1;
					if(aclicks == bclicks) return 0;
					if(aclicks < bclicks) return -1;
					break;
				}
				case Compare.STATE: {
					result = strcmp(a.state, b.state);
					break;
				}
				case Compare.DATE: {
					result = strcmp(a.clicktimestamp, b.clicktimestamp);
					break;
				}
			}
			return result;
		};
	}
}
