using Gtk;
using GLib;

namespace Gradio {

	public class App : Gtk.Application {

		public static MainWindow window;
		public static AudioPlayer player;
		public static Library library;
		public static StationDataProvider data_provider;
		public static GLib.Settings settings;
		public MPRIS mpris;

		public App () {
			Object(application_id: "de.haecker-felix.gradio", flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {
			create_app_menu();

			data_provider = new StationDataProvider();
			data_provider.load_lists.begin();

			player = new AudioPlayer();
			settings = new GLib.Settings ("de.haecker-felix.gradio");

			mpris = new MPRIS();
			mpris.initialize();

			library = new Library();
			library.read_data();

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

		public void add_radio_station(){

		}

		public void edit_radio_station(){

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
			action.activate.connect (() => { this.quit (); });
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

		public static void main (string [] args){
			// Init gstreamer
			unowned string[] argv = null;
			Gst.init (ref argv);

			// Init gtk
			Gtk.init(ref args);

			var app = new App ();
			message("Starting Gradio version " + Constants.VERSION + "!");
			app.run (args);
		}
    }
}
