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

		public string[] page_name = { "library", "discover", "search", "details", "settings", "loading", "station_adress", "collection_items", "add", "collections"};

		private Gradio.Headerbar header;
		PlayerToolbar player_toolbar;

		[GtkChild] private Box SearchBox;
		[GtkChild] SearchBar SearchBar;
		[GtkChild] private MenuButton SearchMenuButton;
		private SearchPopover search_popover;
		private Gd.TaggedEntry SearchEntry;

		[GtkChild] private Stack MainStack;
		[GtkChild] private Overlay NotificationOverlay;
		[GtkChild] private Box Bottom;

		private int height;
		private int width;

		private StatusIcon trayicon;
		public signal void tray_activate();

		StationAddressPage station_address_page;
		CollectionItemsPage collection_items_page;
		DiscoverPage discover_page;
		SearchPage search_page;
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

		private App app;

		public MainWindow (App appl) {
	       		GLib.Object(application: appl);
			app = appl;

			setup_tray_icon();
			setup_view();
			restore_geometry();
			connect_signals();
		}

		private void setup_view(){
			header = new Gradio.Headerbar();
			this.set_titlebar(header);

			selection_toolbar = new SelectionToolbar();
			SelectionToolbarBox.add(selection_toolbar);

			SearchEntry = new Gd.TaggedEntry();
			SearchEntry.set_size_request(550, -1);
			search_page = new SearchPage();
			MainStack.add_named(search_page, page_name[WindowMode.SEARCH]);
			search_popover = new SearchPopover(ref SearchEntry);
			SearchMenuButton.set_popover(search_popover);
			SearchBox.pack_start(SearchEntry);

			station_detail_page = new StationDetailPage();
			MainStack.add_named(station_detail_page, page_name[WindowMode.DETAILS]);

			library_page = new LibraryPage();
			MainStack.add_named(library_page, page_name[WindowMode.LIBRARY]);

			collections_page = new CollectionsPage();
			MainStack.add_named(collections_page, page_name[WindowMode.COLLECTIONS]);

			settings_page = new SettingsPage();
			MainStack.add_named(settings_page, page_name[WindowMode.SETTINGS]);

			station_address_page = new StationAddressPage();
			MainStack.add_named(station_address_page, page_name[WindowMode.STATION_ADDRESS]);

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
			header.AddButton.clicked.connect(show_add);
			header.BackButton.clicked.connect(go_back);
			header.selection_canceled.connect(disable_selection_mode);
			header.selection_started.connect(enable_selection_mode);
			header.search_toggled.connect(() => {
			 	SearchBar.set_search_mode(header.SearchButton.get_active());

			 	if(in_mode_change)
			 		return;

			 	if(current_mode == WindowMode.SEARCH && !(header.SearchButton.get_active()))
			 		go_back();
			});

			SearchBar.notify["search-mode-enabled"].connect(() => header.SearchButton.set_active(SearchBar.get_search_mode()));
			SearchEntry.search_changed.connect(SearchEntry_search_changed);

			NotificationCloseButton.clicked.connect(hide_notification);
		}

		private void setup_tray_icon(){
			trayicon = new StatusIcon.from_icon_name("de.haeckerfelix.gradio-symbolic");
      			trayicon.set_tooltip_text ("Click to restore...");
      			trayicon.set_visible(false);

      			trayicon.activate.connect(() => tray_activate());
		}

		public void show_tray_icon(){
			trayicon.set_visible(true);
		}

		public void hide_tray_icon(){
			trayicon.set_visible(false);
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

			// hide unless we're going to search
			SearchBar.set_search_mode (mode == WindowMode.SEARCH);

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
				case WindowMode.SEARCH:{
					SearchEntry.set_text(data.search); break;
				};
				case WindowMode.DISCOVER: {
					header.show_title("Discover Stations");
					break;
				};
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
					header.SearchButton.set_visible(false);
					break;
				};
				case WindowMode.SETTINGS: {
					header.show_title("Settings");
					header.SelectButton.set_visible(false);
					header.SearchButton.set_visible(false);
					break;
				};
				case WindowMode.STATION_ADDRESS: {
					station_address_page.set_address(data.address);
					station_address_page.set_title(data.title);
					header.show_title(station_address_page.get_title());
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
				case WindowMode.SEARCH: data.search = search_page.get_search(); break;
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

		public void show_discover(){
			if(in_mode_change)
				return;

			if(discover_page == null){
				discover_page = new DiscoverPage();
				MainStack.add_named(discover_page, page_name[WindowMode.DISCOVER]);
			}


			save_back_entry();
			change_mode(WindowMode.DISCOVER);
		}

		public void show_search(){
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

		public void show_stations_by_adress(string address, string title){
			if(in_mode_change)
				return;

			save_back_entry();

			DataWrapper data = new DataWrapper();
			data.address = address;
			data.title  = title;
			change_mode(WindowMode.STATION_ADDRESS, data);
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

		private void SearchEntry_search_changed(){
			string search_term = SearchEntry.get_text();

			if(search_term != "" && search_term.length >= 3){
				if(current_mode != WindowMode.SEARCH){
					save_back_entry();

					DataWrapper data = new DataWrapper();
					data.search = search_term;
					change_mode(WindowMode.SEARCH, data);
				}else{
					search_page.set_search(search_term);
				}
			}
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

			// Toggle Search
			if ((event.keyval == Gdk.Key.f) && (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				if(SearchBar.get_search_mode()){
					SearchBar.set_search_mode(false);
					header.SearchButton.set_active(false);
				}else{
					SearchBar.set_search_mode(true);
					header.SearchButton.set_active(true);
				}
			}


			return false;
		}

	}
}
