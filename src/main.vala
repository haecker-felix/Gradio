using Gtk;

namespace Gradio{

	int main (string[] args){

		Gtk.init (ref args);

		message("Starting Gradio version " + VERSION + "!");
		// Init gstreamer
		Gst.init (ref args);

		// Init gtk
		Gtk.init(ref args);
		//Gtk.main ();

		// Init app
		var app = new App ();

		// Show release notes if neccesary
		if(App.settings != null)
			message("Release notes: " + App.settings.get_string("release-notes"));

		message("Current: " + VERSION);
		if(!(App.settings.get_string("release-notes") == VERSION)){
			ReleaseNotes rn = new ReleaseNotes();
			rn.show();
		}


		// Run app
		app.run (args);



		return 0;
	}

}
