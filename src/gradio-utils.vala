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
				var session = new Soup.Session ();
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
			if(App.settings.enable_notifications){
				var notification = new GLib.Notification (summary);
				notification.set_body (body);
				GLib.Application.get_default ().send_notification ("de.haeckerfelix.gradio", notification);
			}
		}

		public static bool is_collection_item(int id){
			if(id > 1000000) return true;
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
			Gtk.MessageDialog msg = new Gtk.MessageDialog (parent, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, text);
			if (msg.run () == Gtk.ResponseType.OK) {
				msg.close();
				msg.destroy();
			}

			return;
		}

		public static string export_library_dialog (string current_name){
		    Gtk.FileChooserNative export_dialog = new Gtk.FileChooserNative (
                                                     _("Export current library"),
                                                     App.window, Gtk.FileChooserAction.SAVE,
                                                     _("_Export"),
                                                     _("_Cancel"));

			export_dialog.set_current_name(current_name);
			export_dialog.set_do_overwrite_confirmation(true);

			string path = "";
			if (export_dialog.run () == Gtk.ResponseType.ACCEPT) {
				path = export_dialog.get_file().get_path();
			}
			export_dialog.destroy();
			return path;
		}

		public static string import_library_dialog (){
			Gtk.FileChooserNative import_dialog = new Gtk.FileChooserNative (
                                                     _("Select database to import"),
                                                     App.window, Gtk.FileChooserAction.OPEN,
                                                     _("_Import"),
                                                     _("_Cancel"));

			Gtk.FileFilter filter = new Gtk.FileFilter ();
			import_dialog.set_filter (filter);
			filter.add_mime_type ("application/x-sqlite3");


			string path = "";
			if (import_dialog.run () == Gtk.ResponseType.ACCEPT) {
				path = import_dialog.get_file().get_path();
			}
			import_dialog.destroy();
			return path;
		}

		public static string get_sort_string(){
			string sort_variant_string = "";
			switch(App.settings.station_sorting){
				case Compare.VOTES: sort_variant_string = "votes"; break;
				case Compare.NAME: sort_variant_string = "name"; break;
				case Compare.LANGUAGE: sort_variant_string = "language"; break;
				case Compare.COUNTRY: sort_variant_string = "country"; break;
				case Compare.STATE: sort_variant_string = "state"; break;
				case Compare.BITRATE: sort_variant_string = "bitrate"; break;
				case Compare.CLICKS: sort_variant_string = "clickcount"; break;
				case Compare.DATE: sort_variant_string = "clicktimestamp"; break;
			}
			return sort_variant_string;
		}

		public static string get_sortorder_string(){
			string order_variant_string = "";
			if(App.settings.sort_ascending == true) order_variant_string = "ascending"; else order_variant_string = "descending";
			return order_variant_string;
		}


	}
}
