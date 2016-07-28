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
		private Stack DatabaseStack;
		[GtkChild]
		private Stack ContentStack;
		[GtkChild]
		private Box Bottom;
		[GtkChild]
		private MenuButton MenuButton;

		private int height;
		private int width;

		private int pos_x;
		private int pos_y;

		PlayerToolbar player_toolbar;
		DiscoverBox discover_box;
		LibraryBox library_box;

		public signal void toggle_view();

		public MainWindow (App app) {
	       		GLib.Object(application: app);

			width = App.settings.get_int ("window-width");
			height = App.settings.get_int ("window-height");
			this.set_default_size(width, height);

			this.move(pos_x, pos_y);

	       		player_toolbar = new PlayerToolbar();
	       		player_toolbar.set_visible(false);
	       		discover_box = new DiscoverBox();
			library_box = new LibraryBox();

			DatabaseStack.add_titled(library_box, "library_box", _("Library"));
	       		DatabaseStack.add_titled(discover_box, "discover_box", _("Discover"));

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
			MenuButton.set_menu_model(app_menu);

 			if(GLib.Environment.get_variable("DESKTOP_SESSION") == "gnome")
				MenuButton.set_visible (false);
			else
				MenuButton.set_visible (true);
			message("Desktop session is: " + GLib.Environment.get_variable("DESKTOP_SESSION"));

			// Load css
			Util.add_stylesheet("style/style.css");

			ContentStack.set_visible_child_name("database");
	       		Bottom.pack_end(player_toolbar);
			connect_signals();
		}

		public void show_no_connection_message (){
			ContentStack.set_visible_child_name("no_connection");
		}

		private void connect_signals(){
			App.player.radio_station_changed.connect((t,a) => {
				player_toolbar.set_radio_station(a);
			});

			this.destroy.connect(() => {
				App.settings.set_int("window-width", width);
				App.settings.set_int("window-height", height);
			});

			this.size_allocate.connect((a) => {
				width = a.width;
				height = a.height;
			});

			this.drag_motion.connect((c, x, y) => {
				App.settings.set_int("window-position-x", x);
				App.settings.set_int("window-position-y", y);
				return true;
			});
		}

		[GtkCallback]
		private void GridListButton_clicked(Gtk.Button button){
			if(ListImage.get_visible()){
				GridImage.set_visible(true);
				ListImage.set_visible(false);
				library_box.show_list_view();
				discover_box.show_list_view();
			}else{
				GridImage.set_visible(false);
				ListImage.set_visible(true);
				library_box.show_grid_view();
				discover_box.show_grid_view();
			}
		}

	}
}
