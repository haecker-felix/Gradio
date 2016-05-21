using Gtk;
using Gst;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		[GtkChild]
		private Stack ContentStack;
		[GtkChild]
		private Box Bottom;
		[GtkChild]
		private MenuButton MenuButton;

		PlayerToolbar player_toolbar;
		DiscoverBox discover_box;
		LibraryBox library_box;

		public MainWindow (ref GradioApp app, ref PlayerToolbar pt, ref Library lib) {
	       		GLib.Object(application: app);

	       		player_toolbar = pt;
	       		discover_box = new DiscoverBox(ref app, ref lib);
			library_box = new LibraryBox(ref app, ref lib);

			ContentStack.add_titled(library_box, "library_box", "Bibliothek");
	       		ContentStack.add_titled(discover_box, "discover_box", "Suchen");

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
			MenuButton.set_menu_model(app_menu);

 			if(GLib.Environment.get_variable("DESKTOP_SESSION") == "gnome")
				MenuButton.set_visible (false);
			else
				MenuButton.set_visible (true);
			

	       		Bottom.pack_end(player_toolbar);
		}

	}
}
