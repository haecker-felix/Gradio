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
		ManualBox manual_box;
		DiscoverBox discover_box;

		public MainWindow (ref GradioApp app, ref PlayerToolbar pt) {
	       		GLib.Object(application: app);

	       		player_toolbar = pt;
	       		manual_box = new ManualBox(ref app);
	       		discover_box = new DiscoverBox(ref app);

	       		//ContentStack.add_titled(manual_box, "manual_box", "Manuelle Eingabe");
	       		ContentStack.add_titled(discover_box, "discover_box", "Entdecken");
	       		Bottom.pack_end(player_toolbar);
		}

	}
}
