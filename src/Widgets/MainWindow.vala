using Gtk;
using Gst;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {


		[GtkChild]
		private Image GridImage;
		[GtkChild]
		private Image ListImage;
		[GtkChild]
		private Stack ContentStack;
		[GtkChild]
		private Box Bottom;
		[GtkChild]
		private MenuButton MenuButton;

		PlayerToolbar player_toolbar;
		DiscoverBox discover_box;
		LibraryBox library_box;

		public signal void toggle_view();

		public MainWindow (App app) {
	       		GLib.Object(application: app);

	       		player_toolbar = new PlayerToolbar();
	       		discover_box = new DiscoverBox();
			library_box = new LibraryBox();

			ContentStack.add_titled(library_box, "library_box", _("Library"));
	       		ContentStack.add_titled(discover_box, "discover_box", _("Search"));

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
			MenuButton.set_menu_model(app_menu);

 			if(GLib.Environment.get_variable("DESKTOP_SESSION") == "gnome")
				MenuButton.set_visible (false);
			else
				MenuButton.set_visible (true);
			

	       		Bottom.pack_end(player_toolbar);

			connect_signals();
		}

		private void connect_signals(){
			App.player.radio_station_changed.connect((t,a) => {
				player_toolbar.set_radio_station(a);
			});
		}
		
		[GtkCallback]
		private void GridListButton_clicked(Gtk.Button button){
			if(ListImage.get_visible()){
				GridImage.set_visible(true);
				ListImage.set_visible(false);
			}else{
				GridImage.set_visible(false);
				ListImage.set_visible(true);
			}
		}

	}
}
