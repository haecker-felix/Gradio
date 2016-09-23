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
		private Gtk.Menu menuSystem;

		public App () {
			Object(application_id: "de.haeckerfelix.gradio", flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {
			library = new Library();
			library.read_data();

			create_app_menu();

			player = new AudioPlayer();
			settings = new GLib.Settings ("de.haecker-felix.gradio");

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
		}

		public void report_an_error(){
			Util.open_website("https://github.com/haecker-felix/gradio/issues/new");
		}

		private void show_preferences_dialog(){
			SettingsDialog swindow = new SettingsDialog();
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
				"logo-icon-name", "gradio",
				"version", Constants.VERSION,
				"comments", "Database: www.radio-browser.info",
				"website", "https://github.com/haecker-felix/gradio",
				"wrap-license", true);
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

			action = new GLib.SimpleAction ("report_an_error", null);
			action.activate.connect (() => { this.report_an_error (); });
			this.add_action (action);

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;

			set_app_menu (app_menu);
		}

		private void connect_signals(){
			player.connection_error.connect((o,t) => {
				Util.show_info_dialog(t, window);
				return;	
			});
		}

		private void restore_window () {
			var active_window = get_active_window ();
			active_window.present ();
		}

		public void quit_application(){
			restore_window ();
			window.save_geometry ();
			base.quit ();
		}

		private void play_and_stop () {
			App.player.toggle_play_stop();
		}

	    	/* Create menu for right button */
	   	private void create_menuSystem() {
			menuSystem = new Gtk.Menu();
			var menuPlayStop = new Gtk.MenuItem.with_label("Play / Stop");
			menuPlayStop.activate.connect(play_and_stop);
			menuSystem.append(menuPlayStop);
			var menuQuit = new ImageMenuItem.from_stock(Stock.QUIT, null);
			menuQuit.activate.connect(this.quit_application);
			menuSystem.append(menuQuit);
			menuSystem.show_all();
    		}

	    	/* Show popup menu on right button */
	    	private void menuSystem_popup(uint button, uint time) {
			menuSystem.popup(null, null, null, button, time);
		}

		public static void main (string [] args){
			message("Starting Gradio version " + Constants.VERSION + "!");

			// Init gstreamer
			unowned string[] argv = null;
			Gst.init (ref argv);

			// Init gtk
			Gtk.init(ref args);

			// Init app
			var app = new App ();

			// Create tray icon
			var trayicon = new Gtk.StatusIcon.from_icon_name("gradio");
			trayicon.activate.connect(app.restore_window);
			app.create_menuSystem();
			trayicon.popup_menu.connect(app.menuSystem_popup);

			// Show release notes if neccesary
			if(!(settings.get_string("release-notes") == Constants.VERSION)){
				ReleaseNotes rn = new ReleaseNotes();
				rn.show();
			}

			// Run app
			app.run (args);
		}
    }
}
