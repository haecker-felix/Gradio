using Gtk;
using Gst;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private Entry SearchEntry;
		[GtkChild]
		private Button SearchButton;

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
		[GtkChild]
		private StackSwitcher StackSwitcher;
		[GtkChild]
		private ToggleButton MiniPlayerButton;
		[GtkChild]
		private Button GridListButton;

		private MiniPlayer mplayer;

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

			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/app-menu.ui");
			var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
			MenuButton.set_menu_model(app_menu);

 			if(GLib.Environment.get_variable("DESKTOP_SESSION") == "gnome")
				MenuButton.set_visible (false);
			else
				MenuButton.set_visible (true);
			message("Desktop session is: " + GLib.Environment.get_variable("DESKTOP_SESSION"));

			setup_view();
			restore_geometry();
			connect_signals();
		}

		private void setup_view(){
			var gtk_settings = Gtk.Settings.get_default ();
			if (App.settings.get_boolean ("use-dark-design")) {
				gtk_settings.gtk_application_prefer_dark_theme = true;
			} else {
				gtk_settings.gtk_application_prefer_dark_theme = false;
			}

	       		player_toolbar = new PlayerToolbar();
	       		player_toolbar.set_visible(false);
	       		discover_box = new DiscoverBox();
			library_box = new LibraryBox();

			DatabaseStack.add_titled(library_box, "library_box", _("Library"));
	       		DatabaseStack.add_titled(discover_box, "discover_box", _("Discover"));

			mplayer = new MiniPlayer();
			ContentStack.add_titled(mplayer, "miniplayer", _("MiniPlayer"));

			// Load css
			Util.add_stylesheet("style/style.css");

			if(!(App.settings.get_boolean ("use-grid-view"))){
				GridImage.set_visible(true);
				ListImage.set_visible(false);
				library_box.show_list_view();
				discover_box.show_list_view();
				App.settings.set_boolean("use-grid-view", false);
			}else{
				GridImage.set_visible(false);
				ListImage.set_visible(true);
				library_box.show_grid_view();
				discover_box.show_grid_view();
				App.settings.set_boolean("use-grid-view", true);
			}

			ContentStack.set_visible_child_name("database");
	       		Bottom.pack_end(player_toolbar);
		}

		private void connect_signals(){
			this.delete_event.connect (() => {
				save_geometry ();
				if (App.settings.get_boolean ("close-to-tray")) {
					this.hide_on_delete ();
				    return true;
				} else return false;
		    	});

			this.size_allocate.connect((a) => {
				width = a.width;
				height = a.height;
			});

		}

		public void show_mini_player(){
			StackSwitcher.set_visible(false);
			GridListButton.set_visible(false);

			this.set_size_request (10,10);
			this.resize(10,10);
			this.set_resizable(false);
			ContentStack.set_visible_child_name("miniplayer");
		}

		public void show_no_connection_message (){
			MiniPlayerButton.set_visible(false);
			StackSwitcher.set_visible(false);
			GridListButton.set_visible(false);
			ContentStack.set_visible_child_name("no_connection");
		}

		public void show_database(){
			this.set_size_request (920,500);
			this.set_resizable(true);
			MiniPlayerButton.set_visible(true);
			GridListButton.set_visible(true);
			StackSwitcher.set_visible(true);
			ContentStack.set_visible_child_name("database");
		}

		public void save_geometry (){
			this.get_position (out pos_x, out pos_y);
			this.get_size (out width, out height);
			App.settings.set_int("window-width", width);
			App.settings.set_int("window-height", height);
			App.settings.set_int("window-position-x", pos_x);
			App.settings.set_int("window-position-y", pos_y);
			this.move(pos_x, pos_y);
		}

		[GtkCallback]
		private void MiniPlayerButton_toggled(Gtk.ToggleButton button){
			if (button.active) {
				show_mini_player();
			} else {
				show_database();
			}
		}

		public void restore_geometry(){
			width = App.settings.get_int ("window-width");
			height = App.settings.get_int ("window-height");
			this.set_default_size(width, height);
			pos_x = App.settings.get_int ("window-position-x");
			pos_y = App.settings.get_int ("window-position-y");
		}

		[GtkCallback]
		private void SearchButton_clicked(Gtk.Button button){
			discover_box.SearchButton_clicked(SearchEntry.get_text());
		}

		[GtkCallback]
		private void GridListButton_clicked(Gtk.Button button){
			if(ListImage.get_visible()){
				GridImage.set_visible(true);
				ListImage.set_visible(false);
				library_box.show_list_view();
				discover_box.show_list_view();
				App.settings.set_boolean("use-grid-view", false);
			}else{
				GridImage.set_visible(false);
				ListImage.set_visible(true);
				library_box.show_grid_view();
				discover_box.show_grid_view();
				App.settings.set_boolean("use-grid-view", true);
			}
		}

	}
}
