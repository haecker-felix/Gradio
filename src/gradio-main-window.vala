/* This file is part of Gradio.
 *
 * Gradio is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gradio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gradio.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using Gst;

namespace Gradio{

	public enum WindowMode {
		LIBRARY,
		COLLECTIONS,
		COLLECTION_ITEMS,
		SEARCH,
		ADD
	}

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		public string[] page_name = { "library", "collections", "collection_items", "search", "add"};

		public Gradio.Headerbar header;
		PlayerToolbar player_toolbar;

		[GtkChild] private Stack MainStack;
		[GtkChild] private Box Bottom;

		CollectionItemsPage collection_items_page;
		public SearchPage search_page;
		LibraryPage library_page;
		CollectionsPage collections_page;
		AddPage add_page;

		// History of the pages
		GLib.Queue<WindowMode> mode_queue = new GLib.Queue<WindowMode>();
		WindowMode current_mode;
		private bool in_mode_change = false;

		[GtkChild] private Revealer SelectionToolbarRevealer;
		[GtkChild] private Box SelectionToolbarBox;
		private SelectionToolbar selection_toolbar;
		private GLib.List<Gd.MainBoxItem> current_selection;

		[GtkChild] private Button NotificationCloseButton;
		[GtkChild] private Label NotificationLabel;
		//[GtkChild] private Button NotificationButton;
		[GtkChild] private Revealer NotificationRevealer;

		[GtkChild] private Box DetailsBox;
		public DetailsBox details_box;

		public signal void icon_zoom_changed();
		public signal void station_sorting_changed();
		public signal void tray_activate();

		private Gtk.StatusIcon trayicon;

		private App app;

		public MainWindow (App appl) {
	       		GLib.Object(application: appl, show_menubar: false);
			app = appl;
		}

		public void setup(){
			setup_view();
			setup_tray_icon();
			connect_signals();

			this.show_all();
		}

		private void setup_view(){
			header = new Gradio.Headerbar();
			this.set_titlebar(header);

			selection_toolbar = new SelectionToolbar();
			SelectionToolbarBox.add(selection_toolbar);

			library_page = new LibraryPage();
			MainStack.add_named(library_page, page_name[WindowMode.LIBRARY]);

			collections_page = new CollectionsPage();
			MainStack.add_named(collections_page, page_name[WindowMode.COLLECTIONS]);

			collection_items_page = new CollectionItemsPage();
			MainStack.add_named(collection_items_page, page_name[WindowMode.COLLECTION_ITEMS]);

			add_page = new AddPage();
			MainStack.add_named(add_page, page_name[WindowMode.ADD]);

			details_box = new Gradio.DetailsBox();
			DetailsBox.add(details_box);

			// showing library on startup
			set_mode(WindowMode.LIBRARY);

			var gtk_settings = Gtk.Settings.get_default ();
			gtk_settings.gtk_application_prefer_dark_theme = Settings.enable_dark_theme;

	        	player_toolbar = new PlayerToolbar();
	       		player_toolbar.set_visible(false);

	       		Bottom.pack_end(player_toolbar);

	       		// Load css
			Util.add_stylesheet();

			// restore window size
	       		this.set_default_size(Settings.window_width, Settings.window_height);
		}

		private void connect_signals(){
			this.size_allocate.connect((a) => {
				int width, height;
				this.get_size (out width, out height);

			 	Settings.window_width = width;
			 	Settings.window_height = height;
			});

			header.LibraryToggleButton.clicked.connect(() => { set_mode(WindowMode.LIBRARY); });
			header.CollectionsToggleButton.clicked.connect(() => { set_mode(WindowMode.COLLECTIONS); });
			header.SearchToggleButton.clicked.connect(() => { set_mode(WindowMode.SEARCH); });
			header.AddButton.clicked.connect(() => { set_mode(WindowMode.ADD); });
			header.BackButton.clicked.connect(() => {set_mode (mode_queue.pop_head());}); //go one page back in history
			header.selection_canceled.connect(disable_selection_mode);
			header.selection_started.connect(enable_selection_mode);
			NotificationCloseButton.clicked.connect(hide_notification);
		}

		private void setup_tray_icon(){
			trayicon = new Gtk.StatusIcon.from_icon_name("de.haeckerfelix.gradio-symbolic");
      			trayicon.set_tooltip_text ("Click to restore...");
      			trayicon.activate.connect(() => tray_activate());

      			show_tray_icon(Settings.enable_tray_icon);
		}

		public void show_tray_icon(bool b){
			trayicon.set_visible(b);
		}

		public void enable_selection_mode(){
			player_toolbar.set_visible(false);
			Page page = (Page)MainStack.get_visible_child();
			page.set_selection_mode(true);
			SelectionToolbarRevealer.set_reveal_child(true);
			header.show_selection_bar();
		}

		public void disable_selection_mode(){
			if(App.player.station != null)
				player_toolbar.set_visible(true);

			Page page = (Page)MainStack.get_visible_child();
			page.set_selection_mode(false);
			SelectionToolbarRevealer.set_reveal_child(false);
			header.show_default_bar();
		}

		public void select_all(){
			Page page = (Page)MainStack.get_visible_child();
			page.select_all();
		}

		public void select_none(){
			Page page = (Page)MainStack.get_visible_child();
			page.select_none();
		}

		public void selection_changed(){
			Page page = (Page)MainStack.get_visible_child();
			current_selection = page.get_selection();

			selection_toolbar.update_buttons((int)current_selection.length());
			header.set_selected_items((int)current_selection.length());
		}

		public StationModel get_station_selection(){
			StationModel model = new StationModel();

			current_selection.foreach ((station) => {
				model.add_station((RadioStation)station);
			});

			return model;
		}

		public CollectionModel get_collection_selection(){
			CollectionModel model = new CollectionModel();

			current_selection.foreach ((station) => {
				model.add_collection((Collection)station);
			});

			return model;
		}

		public void show_notification(string text){
			NotificationLabel.set_text(text);
			NotificationRevealer.set_reveal_child(true);
		}

		public void hide_notification(){
			NotificationRevealer.set_reveal_child(false);
		}

		public void set_mode(WindowMode mode){
			if(in_mode_change == true)
				return;

			// insert actual mode in the "back" history
			mode_queue.push_head(current_mode);
			in_mode_change = true;

			// set new mode
			current_mode = mode;

			// Disconnect old signals and deactivate selection mode
			Page page = (Page)MainStack.get_visible_child();
			page.set_selection_mode(false);
			selection_toolbar.set_mode(SelectionMode.DEFAULT);
			page.selection_changed.disconnect(selection_changed);
			page.selection_mode_enabled.disconnect(enable_selection_mode);

			// set headerbar to default (disable selection mode, show default buttons), and show toggle the correct button
			header.show_default_bar();
			header.show_default_buttons();
			header.LibraryToggleButton.set_active(mode == WindowMode.LIBRARY);
			header.CollectionsToggleButton.set_active(mode == WindowMode.COLLECTIONS);
			header.SearchToggleButton.set_active(mode == WindowMode.SEARCH);

			// do action for mode
			switch(current_mode){
				case WindowMode.LIBRARY: {
					header.AddButton.set_visible(true);
					selection_toolbar.set_mode(SelectionMode.LIBRARY);
					mode_queue.clear();
					break;
				};
				case WindowMode.COLLECTIONS: {
					selection_toolbar.set_mode(SelectionMode.COLLECTION_OVERVIEW);
					header.SortBox.set_visible(false);
					mode_queue.clear();
					break;
				};
				case WindowMode.SEARCH: {
					if(search_page == null){
						search_page = new SearchPage();
						MainStack.add_named(search_page, page_name[WindowMode.SEARCH]);
					}
					mode_queue.clear();
					break;
				};
				case WindowMode.COLLECTION_ITEMS: {
					Collection collection = collections_page.selected_collection;
					selection_toolbar.set_mode(SelectionMode.COLLECTION_ITEMS, collection.id);
					collection_items_page.set_collection(collection);
					collection_items_page.set_title(collection.name);
					header.show_title(collection_items_page.get_title());
					break;
				};
				case WindowMode.ADD: {
					header.show_title("");
					header.SelectButton.set_visible(false);
					header.ViewButton.set_visible(false);
					break;
				};
			}

			// show back button if needed
			header.BackButton.set_visible(!(mode_queue.is_empty()));

			// switch page
			MainStack.set_visible_child_name(page_name[current_mode]);

			// connect new signals
			Page new_page = (Page)MainStack.get_visible_child();
			new_page.selection_changed.connect(selection_changed);
			new_page.selection_mode_enabled.connect(enable_selection_mode);

			in_mode_change = false;
			message("Changed page mode to \"%s\"", page_name[current_mode]);
		}

		[GtkCallback]
		public bool on_key_pressed (Gdk.EventKey event) {
			var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

			// Quit
			if ((event.keyval == Gdk.Key.q || event.keyval == Gdk.Key.Q) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				app.quit_application();
				return true;
			}

			// Play / Pause
			if ((event.keyval == Gdk.Key.space) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				App.player.toggle_play_stop();
				return true;
			}

			// details sidebar for actual station
			if ((event.keyval == Gdk.Key.i) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				if(App.player.station != null){
					details_box.set_station(App.player.station);
					details_box.set_visible(true);
				}
				return true;
			}

			// show search
			if ((event.keyval == Gdk.Key.f) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				set_mode(WindowMode.SEARCH);
				return true;
			}

			// show library
			if ((event.keyval == Gdk.Key.l) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				set_mode(WindowMode.LIBRARY);
				return true;
			}

			// show collections
			if ((event.keyval == Gdk.Key.c) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				set_mode(WindowMode.COLLECTIONS);
				return true;
			}

			// show add page
			if ((event.keyval == Gdk.Key.a) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				set_mode(WindowMode.ADD);
				return true;
			}
			return false;
		}

	}
}

