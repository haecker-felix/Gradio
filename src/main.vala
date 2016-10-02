using Gtk;

namespace Gradio{

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
