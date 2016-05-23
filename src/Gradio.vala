using Gtk;
using GLib;

namespace Gradio {

	public class GradioApp : Gtk.Application {

		public MainWindow window;
		public AudioPlayer player;
		public PlayerToolbar player_toolbar;
		public Library library;

		public GradioApp () {
			Object(application_id: "de.haecker-felix.gradio", flags: ApplicationFlags.FLAGS_NONE);
		}

		public void set_current_radio_station (RadioStation station){
			player_toolbar.set_radio_station(station);
		}

		protected override void activate () {
			Gradio.GradioApp app = this;

			create_app_menu();

			player = new AudioPlayer();

			library = new Library(ref app);
			library.read_data();

			player_toolbar = new PlayerToolbar(ref app);
			window = new MainWindow(ref app, ref player_toolbar, ref library);	

			this.add_window(window);
			window.show_all();

			connect_signals();
			create_app_menu();
		}	

		private void show_preferences_dialog(){
		
		}

		private void show_about_dialog(){
			string[] authors = {
				"Felix Häcker <haecker.felix1207@gmail.com>"
			};
			string[] artists = {
				"Felix Häcker <haecker.felix1207@gmail.com>"
			};
			Gtk.show_about_dialog (window,
				"artists", artists,
				"authors", authors,
				"translator-credits", _("translator-credits"),
				"program-name", "Gradio",
				"title", "Über Gradio",
				"comments", "GNOME Internet Radio",
				"license-type", Gtk.License.GPL_3_0,
				"logo-icon-name", "gradio",
				"version", "0.2 unstable",
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
			this.add_accelerator ("F1", "app.ABOUT", null);

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;

			set_app_menu (app_menu);	
		}

		private void connect_signals(){
			player.connection_error.connect((o,t) => {
				Util.show_info_dialog("Es ist ein Fehler bei der Wiedergabe aufgetreten: \n" + t, window);
				return;	
			});
		}

		public static void main (string [] args){
			// Init gstreamer
			unowned string[] argv = null;
			Gst.init (ref argv);

			// Init gtk
			Gtk.init(ref args);

			// dark theme
			//Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);

			// run the app
		    	var app = new GradioApp ();
		    	app.run (args);
		}
    }
}
