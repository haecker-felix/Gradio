using Gtk;
using GLib;

namespace Gradio {

	public class GradioApp : Gtk.Application {

		public MainWindow window;
		public AudioPlayer player;
		public PlayerToolbar player_toolbar;

		public GradioApp () {
			Object(application_id: "de.haecker-felix.gradio", flags: ApplicationFlags.FLAGS_NONE);
		}

		public void set_radio_station (RadioStation station){
			player_toolbar.set_radio_stationA(station);
		}

		protected override void activate () {
			Gradio.GradioApp app = this;

			player = new AudioPlayer();
			player_toolbar = new PlayerToolbar(ref app);
			window = new MainWindow(ref app, ref player_toolbar);

			player.connection_error.connect((o,t) => {
				Util.show_info_dialog("Es ist ein Fehler bei der Wiedergabe aufgetreten: \n" + t, window);
				return;	
			});


			this.add_window(window);
			window.show_all();
		}

		public static void main (string [] args){
			// Init gstreamer
			unowned string[] argv = null;
			Gst.init (ref argv);

			// Init gtk
			Gtk.init(ref args);

			// dark theme
			Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);

			// run the app
		    	var app = new GradioApp ();
		    	app.run (args);
		}
    }
}
