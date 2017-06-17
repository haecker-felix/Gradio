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
using GLib;

namespace Gradio {

	public class App : Gtk.Application {

		public static MainWindow window;
		public static AudioPlayer player;
		public static Library library;
		public static MPRIS mpris;
		public static CategoryItemProvider ciprovider;
		public static ImageCache image_cache;

		public App () {
			Object(application_id: "de.haeckerfelix.gradio", flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {
			if (get_windows () == null) {
				message("No existing window, starting new session.");
				start_new_session.begin();

            		} else {
            			message("Found existing window!");
                		restore_window();
			}
		}

		private async void start_new_session(){
			// ignore the vala warning!
			Settings settings = new Settings();

			setup_actions();

			window = new MainWindow(this);
			this.add_window(window);
			window.show_all();

			image_cache = new ImageCache();

			ciprovider = new CategoryItemProvider();

			library = new Library();

			player = new AudioPlayer();

			if(Settings.enable_mpris == true){
				mpris = new MPRIS();
				mpris.initialize();
			}

			connect_signals();
			if(!Util.check_database_connection()){
				Notification n = new Notification("No connection to the database could be established.\nMake sure you can connect to \"radio-browser.info\"!", 1000);
				window.show_notification(n);
			}

			if(Settings.resume_playback_on_startup && Settings.previous_station != 0){
				RadioStation s = yield Util.get_station_by_id(Settings.previous_station);
				player.set_radio_station(s);
			}

			window.setup();
		}

		private void connect_signals(){
			mpris.requested_quit.connect(() => quit_application());
			mpris.requested_raise.connect(() => restore_window());

			window.delete_event.connect (() => {
				window.save_geometry ();

				window.hide_on_delete ();
				return Settings.enable_background_playback;
		    	});
		}

		private void setup_actions () {
			// Appmenu
			var action = new GLib.SimpleAction ("preferences", null);
			action.activate.connect (() => { window.show_settings (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("about", null);
			action.activate.connect (() => { this.show_about_dialog (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("quit", null);
			action.activate.connect (() => { this.quit_application (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("report_an_error", null);
			action.activate.connect (() => { this.report_an_error (); });
			this.add_action (action);

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/ui/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;

			set_app_menu (app_menu);


			action = new GLib.SimpleAction ("select-all", null);
			action.activate.connect (() => { window.select_all(); });
			this.add_action (action);

			action = new GLib.SimpleAction ("select-none", null);
			action.activate.connect (() => { window.select_none (); });
			this.add_action (action);
		}

		public void report_an_error(){
			Util.open_website("https://github.com/haecker-felix/gradio/issues/new");
		}

		private void show_about_dialog(){
			string[] authors = {
				"Felix Häcker <haecker.felix1207@gmail.com>"
			};
			string[] artists = {
				"Juan Pablo Lozano <lozanotux@gmail.com>"
			};
			Gtk.show_about_dialog (window,
				"artists", artists,
				"authors", authors,
				"translator-credits", "translator-credits",
				"program-name", "Gradio",
				"title", "About Gradio",
				"license-type", Gtk.License.GPL_3_0,
				"logo-icon-name", "de.haeckerfelix.gradio",
				"version", Config.VERSION,
				"comments", "Database: www.radio-browser.info",
				"website", "https://github.com/haecker-felix/gradio",
				"wrap-license", true);
		}


		public void restore_window () {
			if(window != null)
				window.present();
		}

		public void quit_application(){
			restore_window ();
			window.save_geometry ();
			base.quit ();
		}
	}

	int main (string[] args){
		message("Gradio %s ", Config.VERSION);

		// Init gstreamer
		Gst.init (ref args);

		// Init gtk
		Gtk.init(ref args);

		// Init app
		var app = new App ();

		// Run app
		app.run (args);

		return 0;
	}
}
