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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		public string[] page_name = { "library", "search", "details", "settings", "collection_items", "add", "collections"};

		private Gradio.Headerbar header;
		PlayerToolbar player_toolbar;

		[GtkChild] private Stack MainStack;
		[GtkChild] private Box Bottom;

		private int height;
		private int width;

		CollectionItemsPage collection_items_page;
		public SearchPage search_page;
		LibraryPage library_page;
		CollectionsPage collections_page;
		SettingsPage settings_page;
		StationDetailPage station_detail_page;
		AddPage add_page;

		GLib.Queue<BackEntry> back_entry_stack = new GLib.Queue<BackEntry>();
		WindowMode current_mode;
		bool in_mode_change;

		[GtkChild] private Revealer SelectionToolbarRevealer;
		[GtkChild] private Box SelectionToolbarBox;
		private SelectionToolbar selection_toolbar;
		private GLib.List<Gd.MainBoxItem> current_selection;

		[GtkChild] private Button NotificationCloseButton;
		[GtkChild] private Label NotificationLabel;
		[GtkChild] private Button NotificationButton;
		[GtkChild] private Revealer NotificationRevealer;

		public signal void update_icons();

		private App app;

		public MainWindow (App appl) {
	       		GLib.Object(application: appl);
			app = appl;
		}

		public void setup(){
			setup_view();
			restore_geometry();
			connect_signals();

			this.show_all();
		}

		private void setup_view(){
			header = new Gradio.Headerbar();
			this.set_titlebar(header);

			selection_toolbar = new SelectionToolbar();
			SelectionToolbarBox.add(selection_toolbar);

			station_detail_page = new StationDetailPage();
			MainStack.add_named(station_detail_page, page_name[WindowMode.DETAILS]);

			library_page = new LibraryPage();
			MainStack.add_named(library_page, page_name[WindowMode.LIBRARY]);

			collections_page = new CollectionsPage();
			MainStack.add_named(collections_page, page_name[WindowMode.COLLECTIONS]);

			settings_page = new SettingsPage();
			MainStack.add_named(settings_page, page_name[WindowMode.SETTINGS]);

			collection_items_page = new CollectionItemsPage();
			MainStack.add_named(collection_items_page, page_name[WindowMode.COLLECTION_ITEMS]);

			add_page = new AddPage();
			MainStack.add_named(add_page, page_name[WindowMode.ADD]);

			// showing library on startup
			change_mode(WindowMode.LIBRARY);

			var gtk_settings = Gtk.Settings.get_default ();
			if (Settings.enable_dark_theme) {
				gtk_settings.gtk_application_prefer_dark_theme = true;
			} else {
				gtk_settings.gtk_application_prefer_dark_theme = false;
			}

	        	player_toolbar = new PlayerToolbar();
	       		player_toolbar.set_visible(false);

			//Load css
			Util.add_stylesheet();
	       		Bottom.pack_end(player_toolbar);
		}

		private void connect_signals(){
			this.size_allocate.connect((a) => {
			 	width = a.width;
			 	height = a.height;
			});

			header.LibraryToggleButton.clicked.connect(show_library);
			header.CollectionsToggleButton.clicked.connect(show_collections);
			header.SearchToggleButton.clicked.connect(show_search);
			header.AddButton.clicked.connect(show_add);
			header.BackButton.clicked.connect(go_back);
			header.selection_canceled.connect(disable_selection_mode);
			header.selection_started.connect(enable_selection_mode);
			NotificationCloseButton.clicked.connect(hide_notification);
		}

		public void save_geometry (){
			this.get_size (out width, out height);

			Settings.window_height = height;
			Settings.window_width = width;
		}

		public void restore_geometry(){
			width = Settings.window_width;
			height = Settings.window_height;
		}

		public void enable_selection_mode(){
			player_toolbar.set_visible(false);
			Page page = (Page)MainStack.get_visible_child();
			page.set_selection_mode(true);
			SelectionToolbarRevealer.set_reveal_child(true);
			header.show_selection_bar();
		}

		public void disable_selection_mode(){
			if(App.player.current_station != null)
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

		public void show_notification(Notification notification){
			NotificationLabel.set_text(notification.message);
			NotificationRevealer.set_reveal_child(true);
		}

		public void hide_notification(){
			NotificationRevealer.set_reveal_child(false);
		}

		private void change_mode(WindowMode mode, DataWrapper data = new DataWrapper()){
			in_mode_change = true;

			// deactivate selection mode
			Page page = (Page)MainStack.get_visible_child();
			page.set_selection_mode(false);
			selection_toolbar.set_mode(SelectionMode.DEFAULT);
			header.show_default_bar();

			// disconnect old selection_changed signal
			page.selection_changed.disconnect(selection_changed);
			page.selection_mode_enabled.disconnect(enable_selection_mode);

			// show defaults in the headerbar
			header.show_default_buttons();

			// update main buttons according to mode
			header.LibraryToggleButton.set_active(mode == WindowMode.LIBRARY);
			header.CollectionsToggleButton.set_active(mode == WindowMode.COLLECTIONS);
			header.SearchToggleButton.set_active(mode == WindowMode.SEARCH);

			// setting new mode
			current_mode = mode;

			// switch page
			MainStack.set_visible_child_name(page_name[current_mode]);

			// connect new signals
			Page new_page = (Page)MainStack.get_visible_child();
			new_page.selection_changed.connect(selection_changed);
			new_page.selection_mode_enabled.connect(enable_selection_mode);

			// do action for mode
			switch(current_mode){
				case WindowMode.LIBRARY: {
					header.AddButton.set_visible(true);
					selection_toolbar.set_mode(SelectionMode.LIBRARY);
					clean_back_entry_stack();
					break;
				};
				case WindowMode.COLLECTIONS: {
					selection_toolbar.set_mode(SelectionMode.COLLECTION_OVERVIEW);
					clean_back_entry_stack();
					break;
				};
				case WindowMode.DETAILS: {
					station_detail_page.set_station((RadioStation)data.station);
					header.show_title(station_detail_page.get_title());
					header.SelectButton.set_visible(false);
					header.SearchToggleButton.set_visible(false);
					header.ViewButton.set_visible(false);
					break;
				};
				case WindowMode.SETTINGS: {
					header.show_title("Settings");
					header.SelectButton.set_visible(false);
					header.SearchToggleButton.set_visible(false);
					header.ViewButton.set_visible(false);
					break;
				};
				case WindowMode.COLLECTION_ITEMS: {
					selection_toolbar.set_mode(SelectionMode.COLLECTION_ITEMS, data.collection.id);
					collection_items_page.set_collection(data.collection);
					collection_items_page.set_title(data.title);
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
			header.BackButton.set_visible(current_mode != WindowMode.SEARCH && !(back_entry_stack.is_empty()));

			in_mode_change = false;

			message("Changed page mode to \"%s\"", page_name[current_mode]);
		}

		private void clean_back_entry_stack(){
			back_entry_stack.clear();
		}

		private void go_back(){
			BackEntry entry = back_entry_stack.pop_head();

			if(entry != null){
				switch(entry.mode){
					case WindowMode.DETAILS: change_mode(entry.mode, entry.data); break;
					case WindowMode.SEARCH: change_mode(entry.mode, entry.data); break;
					default: change_mode (entry.mode); break;
				}
			}
		}

		private void save_back_entry(){
			BackEntry entry = new BackEntry();
			DataWrapper data = new DataWrapper();

			entry.mode = current_mode;

			switch(entry.mode){
				case WindowMode.DETAILS: data.station = station_detail_page.get_station(); break;
				default: break;
			}

			entry.data = data;
			back_entry_stack.push_head(entry);
		}

		public void show_library(){
			if(in_mode_change)
				return;

			save_back_entry();
			change_mode(WindowMode.LIBRARY);
		}

		public void show_collections(){
			if(in_mode_change)
				return;

			save_back_entry();
			change_mode(WindowMode.COLLECTIONS);
		}

		public void show_search(){
			if(search_page == null){
				search_page = new SearchPage();
				MainStack.add_named(search_page, page_name[WindowMode.SEARCH]);
			}

			if(in_mode_change)
				return;

			save_back_entry();
			change_mode(WindowMode.SEARCH);
		}

		public void show_station_details(RadioStation station){
			if(in_mode_change)
				return;

			// dont open the same details page twice times
			if(station_detail_page.get_station() == null ||  current_mode != WindowMode.DETAILS){
				save_back_entry();
				DataWrapper data = new DataWrapper();
				data.station = station;
				change_mode(WindowMode.DETAILS, data);
			}
		}

		public void show_settings(){
			if(in_mode_change)
				return;

			save_back_entry();
			change_mode(WindowMode.SETTINGS);
		}

		public void show_collection_items(Collection coll, string title){
			if(in_mode_change)
				return;

			save_back_entry();

			DataWrapper data = new DataWrapper();
			data.collection = coll;
			data.title  = title;
			change_mode(WindowMode.COLLECTION_ITEMS, data);
		}

		public void show_add(){
			if(in_mode_change)
				return;

			save_back_entry();
			change_mode(WindowMode.ADD);
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

			return false;
		}

	}
}
