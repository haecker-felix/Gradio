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
	public class Util{

		public static async string get_string_from_uri (string url){
			if(url != ""){
				var session = new Soup.SessionAsync ();
				session.user_agent = "gradio/"+ Config.VERSION;
				var message = new Soup.Message ("GET", url);

				session.queue_message (message, (session, msg) => {
		        		get_string_from_uri.callback ();
		    		});
				yield;

				if((string)message.response_body.data != null){
					return (string)message.response_body.data;
				}

			}
			return "";
		}

		public static bool check_database_connection(){
			var host = "www.radio-browser.info";

			try {
				Resolver resolver = Resolver.get_default ();
				resolver.lookup_by_name (host, null);

				return true;
			} catch (Error e) {
				critical (e.message);
				return false;
			}
		}

		public static void add_stylesheet () {
			var provider = new CssProvider ();

			provider.load_from_resource ("/de/haecker-felix/gradio/de.haeckerfelix.gradio.style.css");
			StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		}

		public static void send_notification(string summary, string body, Gdk.Pixbuf? icon = null){
			var notification = new GLib.Notification (summary);
			notification.set_body (body);
			GLib.Application.get_default ().send_notification ("de.haeckerfelix.gradio", notification);
		}

		public static bool is_collection_item(int id){
			if(id > 1000000)
				return true;
			return false;
		}

		public static async RadioStation get_station_by_id(int id){
			Json.Parser parser = new Json.Parser ();
			RadioStation new_station = null;

			string data = yield Util.get_string_from_uri(RadioBrowser.radio_stations_by_id + id.to_string());

			if(data != ""){
				try{
					parser.load_from_data (data);
				}catch (Error e){
					critical("Could create new station: " + e.message);
				}

				var root = parser.get_root ();
				var radio_stations = root.get_array ();

				if(radio_stations.get_length() != 0){
					var radio_station = radio_stations.get_element(0);
					var radio_station_data = radio_station.get_object ();

					new_station = new RadioStation.from_json_data(radio_station_data);
				}else{
					warning("Empty station data");
				}
			}
			return new_station;
		}

		public static bool show_yes_no_dialog(string text, Gtk.Window parent){
			bool result = false;

			Gtk.MessageDialog msg = new Gtk.MessageDialog (parent, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO, text);
			if (msg.run () == Gtk.ResponseType.YES) {
				result = true;
			}
			msg.close();
			msg.destroy();
			return result;
		}

		public static void show_info_dialog(string text, Gtk.Window parent){

		}

		public static string open_file (string description, Gtk.Window parent){
			Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
				description, parent, Gtk.FileChooserAction.OPEN,
				"_Cancel",
				Gtk.ResponseType.CANCEL,
				"_Open",
				Gtk.ResponseType.ACCEPT);

			Gtk.FileFilter filter = new Gtk.FileFilter ();
			chooser.set_filter (filter);
			filter.add_mime_type ("application/x-sqlite3");


			string path = "";
			if (chooser.run () == Gtk.ResponseType.ACCEPT) {
				path = chooser.get_file().get_path();
			}
			chooser.close();
			chooser.destroy();
			return path;
		}
	}
}



