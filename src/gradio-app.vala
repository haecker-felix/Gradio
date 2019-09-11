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

		public static Settings settings;
		public static MainWindow window;
		public static AudioPlayer player;
		public static Library library;
		public static MPRIS mpris;
		public static ImageCache image_cache;

		private SearchProvider search_provider;
		private uint search_provider_id = 0;

		public App() {
			Object(application_id: "de.haeckerfelix.gradio", flags: ApplicationFlags.FLAGS_NONE);

			// Load application settings
			settings = new Settings();

			// GNOME shell search
			search_provider = new SearchProvider ();
			search_provider.activate.connect ((timestamp, station_id) => {
				ensure_window ();
				window.present_with_time (timestamp);

				Util.get_station_by_id.begin(int.parse(station_id), (obj,res) => {
					RadioStation station = Util.get_station_by_id.end(res);
					player.station = station;
				});
			});
			search_provider.start_search.connect ((timestamp, searchterm) => {
				ensure_window ();
				window.present_with_time (timestamp);
				window.set_mode(WindowMode.SEARCH);
				window.search_page.set_search(searchterm);
			});

                        Environment.set_variable("PULSE_PROP_media.role", "music", true);
                        Environment.set_variable("PULSE_PROP_application.icon_name", "de.haeckerfelix.gradio", true);
                        Environment.set_application_name("Gradio");
		}

		protected override void startup () {
			base.startup ();

			// Check for for internet access TODO: Improve internet check. This just should be a workaround.
			if(!Util.check_database_connection()){
				warning("Gradio cannot connect radio-browser.info. Please check your internet connection.");
				this.quit();
			}

			// Setup application actions
			setup_actions();

			// Setup audio backend
			player = new AudioPlayer();

			// Setup image cache
			image_cache = new ImageCache();

			// Load station and collection library
			library = new Library();

			// Enable MPRIS, if it is enabled in the settings
			if(settings.enable_mpris == true){
				mpris = new MPRIS();
				mpris.initialize();
				mpris.requested_quit.connect(this.quit);
				mpris.requested_raise.connect(() => window.present());
			}
		}

		protected override void activate () {
			base.activate();
			ensure_window();
			window.present();
		}

		private void setup_actions () {
			// setup actions itself
			var action = new GLib.SimpleAction ("preferences", null);
			action.activate.connect (() => { window.set_mode(WindowMode.SETTINGS); });
			this.add_action (action);

			action = new GLib.SimpleAction ("about", null);
			action.activate.connect (() => { this.show_about_dialog (); });
			this.add_action (action);

			action = new GLib.SimpleAction ("opendatabase", null);
			action.activate.connect (() => {
				try{
					Gtk.show_uri(null, "http://radio-browser.info", 0);
				}catch(Error e){
					warning(e.message);
				}
			});
			this.add_action (action);

			action = new GLib.SimpleAction ("quit", null);
			action.activate.connect (this.quit);
			this.add_action (action);

			action = new GLib.SimpleAction ("select-all", null);
			action.activate.connect (() => { window.select_all(); });
			this.add_action (action);

			action = new GLib.SimpleAction ("select-none", null);
			action.activate.connect (() => { window.select_none (); });
			this.add_action (action);
		}

		public override bool dbus_register (DBusConnection connection, string object_path) {
			try {
				search_provider_id = connection.register_object (object_path + "/SearchProvider", search_provider);
				message("Registered search provider service.");
			} catch (IOError error) {
				warning ("Could not register search provider service: %s\n", error.message);
			}
			return true;
		}

		public override void dbus_unregister (DBusConnection connection, string object_path) {
			if (search_provider_id != 0) {
				connection.unregister_object (search_provider_id);
				search_provider_id = 0;
				message("Unregistered search provider service.");
			}
		}

		private void show_about_dialog(){
			string[] authors = { "Felix Häcker <haeckerfelix@gnome.org>" };
			string[] artists = { "Juan Pablo Lozano <lozanotux@gmail.com>" };

			Gtk.show_about_dialog (window,
				"artists", artists,
				"authors", authors,
				"program-name", "Gradio",
				"license-type", Gtk.License.GPL_3_0,
				"logo-icon-name", "de.haeckerfelix.gradio",
				"version", Config.VERSION,
				"comments", _("Find and listen to internet radio stations."),
				"website", "https://github.com/haecker-felix/gradio",
				"website-label", _("GitHub Homepage"));
		}

		// make sure that window != null, but don't present it
		private void ensure_window(){
			if (get_windows () != null) return;

			window = new MainWindow(this);
			window.delete_event.connect (() => {
				window.hide_on_delete ();

				if(player.state == Gst.State.PLAYING && settings.enable_background_playback)
					return true;
				else
					return false;
		    	});
			window.tray_activate.connect(window.present);
			this.add_window(window);
		}
	}

	int main (string[] args){
		message("Gradio %s ", Config.VERSION);

		// Setup gettext
		Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
		Intl.setlocale(LocaleCategory.ALL, "");
		Intl.textdomain(Config.GETTEXT_PACKAGE);
		Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "utf-8");

		message("Locale dir: " + Config.GNOMELOCALEDIR);

		// Init gstreamer
		Gst.init (ref args);

		// Init gtk
		Gtk.init(ref args);

		// Init app
		var app = new App ();

		// Run app
		app.run (args);
		App.settings.apply();

		return 0;
	}
}
