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

		public MainWindow (ref GradioApp app, ref PlayerToolbar pt) {
	       		GLib.Object(application: app);

	       		player_toolbar = pt;
	       		discover_box = new DiscoverBox(ref app);

	       		ContentStack.add_titled(discover_box, "discover_box", "Entdecken");
	       		Bottom.pack_end(player_toolbar);
		}

	}
}
