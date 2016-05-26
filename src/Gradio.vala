using Gtk;
using GLib;

namespace Gradio {

	public class GradioApp : Gtk.Application {

		public MainWindow window;
		public AudioPlayer player;
		public PlayerToolbar player_toolbar;

		public Library library;
		public GLib.Settings settings;

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
			settings = new GLib.Settings ("de.haecker-felix.gradio");

			library = new Library(ref app);
			library.read_data();

			player_toolbar = new PlayerToolbar(ref app);
			window = new MainWindow(ref app, ref player_toolbar, ref library);	

			this.add_window(window);
			window.show_all();

			connect_signals();
			create_app_menu();
		}	

		public void report_an_error(){
			Util.open_website("https://github.com/haecker-felix/gradio/issues/new");
		}

		private void show_preferences_dialog(){
			SettingsDialog swindow = new SettingsDialog(this);
			swindow.show();
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
				"title", _("About Gradio"),
				"license-type", Gtk.License.GPL_3_0,
				"logo-icon-name", "gradio",
				"version", "1.01",
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

			player.new_radio_station.connect(() => {
				if(settings.get_boolean ("show-notifications")){
					Notification notify = new Notification("Gradio");
					notify.set_priority (NotificationPriority.LOW);
					notify.set_body(player.current_station.Title);
					this.send_notification("1212", notify);	
				}
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
			
			var app = new GradioApp ();
			if(Util.check_database_connection()){
				app.run (args);
			}else{
				warning("Cannot connect to the database. Is your internet connection working?");
			}
						



			
		

		}
    }
}
