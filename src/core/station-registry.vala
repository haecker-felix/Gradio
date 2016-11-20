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
	public class StationRegistry{

		public static int counter = 0;
		public static int active_stations = 0;

		static StationRegistry(){

		}

		public static int register_station(RadioStation s){
			counter++;
			active_stations++;

			s.added_to_library.connect(added_to_library_handler);
			s.removed_from_library.connect(removed_from_library_handler);
			s.played.connect(playing_handler);

			message("[%i] \"%s\" is registered. (%i active stations)", counter, s.Title, active_stations);
			return counter;
		}

		public static void unregister_station(RadioStation s){
			active_stations--;

			s.added_to_library.disconnect(added_to_library_handler);
			s.removed_from_library.disconnect(removed_from_library_handler);
			s.played.disconnect(playing_handler);

			message("[%i] \"%s\" is unregistered (%i active stations)", counter, s.Title, active_stations);
		}

		private static void added_to_library_handler(int cid){
			message("[%i] added to library", cid);
		}

		private static void removed_from_library_handler(int cid){
			message("[%i] removed from library", cid);
		}

		private static void playing_handler(int cid){
			message("[%i] is now playing", cid);
		}
	}
}
