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

using Gtk;

namespace Gradio{
	public class AdditionalDataProvider{

		public static void get_additional_image(RadioStation station){

		}

		// Returns the html description metadata
		// Much mess here. Feel free to improve this crap :)
		public static async string get_description(RadioStation station){
			SourceFunc callback = get_description.callback;

			string descr = "";
			string html = "";

			// download the html
			Util.get_string_from_uri.begin(station.Homepage, (obj, res) => {
				string result = Util.get_string_from_uri.end(res);

				if(result != null)
					html = result;
				Idle.add((owned) callback);
			});

			yield;

			// search description metadata
			int start_index = html.index_of("<meta name=\"description\" content=\"");
			int end_index = -1;
			int html_length = html.length;

			// take the root if no description found. http://bla.org/da/da/da/da -> http://bla.org
			if(start_index == -1 && station.Homepage != null && station.Homepage != ""){
				string url = station.Homepage;
				//message("Before: %s", url);

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

				//message("After: %s", url);
				station.Homepage = url;

				// process the new address
				descr = "";
				html = "";

				Util.get_string_from_uri.begin(station.Homepage, (obj, res) => {
					string result = Util.get_string_from_uri.end(res);

					if(result != null)
						html = result;
					Idle.add((owned) callback);
				});

				yield;

				start_index = html.index_of("<meta name=\"description\" content=\"");
				end_index = -1;
				html_length = html.length;
			}

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
			//message(">> %s", station.Title);
			//message("Homepage: %s", station.Homepage);
			//message("HTML Lenght: %i", html_length);
			//message("Start index: %i", start_index);
			//message("End index: %i", end_index);

			return descr;
		}

		public static void get_station_image(RadioStation station){

		}
	}
}
