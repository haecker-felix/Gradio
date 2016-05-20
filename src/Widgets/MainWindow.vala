using Gtk;
using Gst;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		[GtkChild]
		private Stack ContentStack;
		[GtkChild]
		private Box Bottom;

		PlayerToolbar player_toolbar;
		DiscoverBox discover_box;
		LibraryBox library_box;

		public MainWindow (ref GradioApp app, ref PlayerToolbar pt) {
	       		GLib.Object(application: app);

	       		player_toolbar = pt;
	       		discover_box = new DiscoverBox(ref app);
			library_box = new LibraryBox(ref app);

			ContentStack.add_titled(library_box, "library_box", "Bibliothek");
	       		ContentStack.add_titled(discover_box, "discover_box", "Suchen");

	       		Bottom.pack_end(player_toolbar);
		}

	}
}
