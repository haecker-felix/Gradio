using Gtk;

namespace Gradio{

	int main (string[] args){

		Gtk.init (ref args);

		/*
		    var window = new Window ();
		    window.title = "First GTK+ Program";
		    window.border_width = 10;
		    window.window_position = WindowPosition.CENTER;
		    window.set_default_size (350, 70);
		    window.destroy.connect (Gtk.main_quit);

		    var button = new Button.with_label ("Click me!");
		    button.clicked.connect (() => {
			button.label = "Thank you";
		    });

		    window.add (button);
		    window.show_all ();

		    Gtk.main ();
		    return 0;
		*/

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
