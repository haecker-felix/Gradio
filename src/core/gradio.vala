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

		public static ImageProvider imgprovider;
		public static MainWindow window;
		public static AudioPlayer player;
		public static Library library;
		public static GLib.Settings settings;
		public static MPRIS mpris;

		public App () {
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			Object(application_id: "de.haeckerfelix.gradio", flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {

			if (get_windows () == null) {
				message("No existing window, starting new session.");

                		library = new Library();
				library.read_data();

				create_app_menu();

				player = new AudioPlayer();

				mpris = new MPRIS();
				mpris.initialize();

				imgprovider = new ImageProvider();

				window = new MainWindow(this);
				this.add_window(window);
				window.show_all();

				connect_signals();
				if(!Util.check_database_connection()){
					window.show_no_connection_message();
				}
            		} else {
            			message("Found existing session!");
                		window.present ();
			}
		}

		private void connect_signals(){
			player.connection_error.connect((o,t) => {
				Util.show_info_dialog(t, window);
				return;
			});

			mpris.requested_quit.connect(() => quit_application());
			mpris.requested_raise.connect(() => restore_window());

			window.delete_event.connect (() => {
				window.save_geometry ();
				if (Settings.enable_background_playback) {
					window.hide_on_delete ();
					if(Settings.enable_close_to_tray){
						show_tray_icon();
						message("Minimized to tray");
					}
				    	return true;
				} else return false;
		    	});
		}

		private void create_app_menu () {
			var action = new GLib.SimpleAction ("preferences", null);
			action.activate.connect (() => { this.show_preferences_dialog (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("about", null);
			action.activate.connect (() => { this.show_about_dialog (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("quit", null);
			action.activate.connect (() => { this.quit_application (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("release_notes", null);
			action.activate.connect (() => { this.release_notes (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("report_an_error", null);
			action.activate.connect (() => { this.report_an_error (); });
			this.add_action (action);

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/ui/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;

			set_app_menu (app_menu);
		}

		public void report_an_error(){
			Util.open_website("https://github.com/haecker-felix/gradio/issues/new");
		}

		public void release_notes(){
			ReleaseNotesWindow rn = new ReleaseNotesWindow();
			rn.show_all();
		}

		private void show_preferences_dialog(){
			SettingsWindow swindow = new SettingsWindow();
			swindow.set_transient_for(window);
			swindow.show();
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
				"translator-credits", _("translator-credits"),
				"program-name", "Gradio",
				"title", _("About Gradio"),
				"license-type", Gtk.License.GPL_3_0,
				"logo-icon-name", "de.haeckerfelix.gradio",
				"version", VERSION,
				"comments", "Database: www.radio-browser.info",
				"website", "https://github.com/haecker-felix/gradio",
				"wrap-license", true);
		}

		private void show_tray_icon(){

		}

		private void hide_tray_icon(){

		}

		public void restore_window () {
			var active_window = get_active_window ();
			active_window.present ();
			hide_tray_icon();
		}

		public void quit_application(){
			restore_window ();
			window.save_geometry ();
			base.quit ();
		}
	}

	int main (string[] args){
		message("Starting Gradio version " + VERSION + "!");

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
