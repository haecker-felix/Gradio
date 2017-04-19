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

using Gd;
using Gtk;
using Gst;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/main-window.ui")]
	public class MainWindow : Gtk.ApplicationWindow {

		public string[] page_name = { "library", "discover", "search", "details", "settings", "loading" };

		[GtkChild] private Box SearchBox;
		[GtkChild] SearchBar SearchBar;
		[GtkChild] private ToggleButton SearchButton;
		[GtkChild] private MenuButton SearchMenuButton;
		private SearchPopover search_popover;
		private TaggedEntry SearchEntry;

		[GtkChild] private Stack MainStack;
		[GtkChild] private Overlay NotificationOverlay;

		[GtkChild] private Box Bottom;
		[GtkChild] private VolumeButton VolumeButton;
		[GtkChild] private Button BackButton;

		[GtkChild] private ButtonBox MainButtonBox;
		[GtkChild] private ToggleButton DiscoverToggleButton;
		[GtkChild] private ToggleButton LibraryToggleButton;

		private int height;
		private int width;

		private StatusIcon trayicon;
		public signal void toggle_view();
		public signal void tray_activate();

		PlayerToolbar player_toolbar;

		DiscoverPage discover_page;
		SearchPage search_page;
		LibraryPage library_page;
		SettingsPage settings_page;
		StationDetailPage station_detail_page;

		GLib.Queue<BackEntry> back_entry_stack = new GLib.Queue<BackEntry>();
		WindowMode current_mode;
		bool in_mode_change;

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
			SearchEntry = new TaggedEntry();
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

			discover_page = new DiscoverPage();
			MainStack.add_named(discover_page, page_name[WindowMode.DISCOVER]);

			settings_page = new SettingsPage();
			MainStack.add_named(settings_page, page_name[WindowMode.SETTINGS]);

			// showing library on startup
			change_mode(WindowMode.LIBRARY);

			VolumeButton.set_relief(ReliefStyle.NORMAL);
			VolumeButton.set_value(Settings.volume_position);

			var gtk_settings = Gtk.Settings.get_default ();
			if (Settings.enable_dark_design) {
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

			LibraryToggleButton.clicked.connect(show_library);
			DiscoverToggleButton.clicked.connect(show_discover);
			BackButton.clicked.connect(go_back);
			SearchBar.notify["search-mode-enabled"].connect(() => SearchButton.set_active(SearchBar.get_search_mode()));
			SearchEntry.search_changed.connect(SearchEntry_search_changed);
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

		public void show_no_connection_message (){
			VolumeButton.set_visible(false);
			MainStack.set_visible_child_name("no_connection");
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


		public void show_notification(Gradio.Notification notification){
			NotificationOverlay.add_overlay(notification);
			this.show_all();
		}

		private void change_mode(WindowMode mode, DataWrapper data = new DataWrapper()){
			in_mode_change = true;

			// update main buttons according to mode
			DiscoverToggleButton.set_active(mode == WindowMode.DISCOVER);
			LibraryToggleButton.set_active(mode == WindowMode.LIBRARY);

			// hide unless we're going to search
			SearchBar.set_search_mode (mode == WindowMode.SEARCH);


			// setting new mode
			current_mode = mode;

			// switch page
			MainStack.set_visible_child_name(page_name[current_mode]);

			// do action for mode
			switch(current_mode){
				case WindowMode.SEARCH:{
					SearchEntry.set_text(data.search); break;
				};
				case WindowMode.DISCOVER: {
					clean_back_entry_stack();
					break;
				};
				case WindowMode.LIBRARY: {
					clean_back_entry_stack();
					break;
				};
				case WindowMode.DETAILS: {
					station_detail_page.set_station((RadioStation)data.station);
					break;
				};
			}

			// show back button if needed
			BackButton.set_visible(current_mode != WindowMode.SEARCH && !(back_entry_stack.is_empty()));

			in_mode_change = false;

			message("Changed mode to " + page_name[current_mode] + "page");
		}

		private void clean_back_entry_stack(){
			message("cleand back_entry_stack");
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

		public void show_discover(){
			if(in_mode_change)
				return;

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

			save_back_entry();

			DataWrapper data = new DataWrapper();
			data.station = station;
			change_mode(WindowMode.DETAILS, data);
		}

		public void show_settings(){
			if(in_mode_change)
				return;

			save_back_entry();
			change_mode(WindowMode.SETTINGS);
		}

		[GtkCallback]
		private void SearchButton_toggled (){
			SearchBar.set_search_mode(SearchButton.get_active());

			if(in_mode_change)
				return;

			if(current_mode == WindowMode.SEARCH && !(SearchButton.get_active()))
				go_back();

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
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			Settings.volume_position = value;
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
					SearchButton.set_active(false);
				}else{
					SearchBar.set_search_mode(true);
					SearchButton.set_active(true);
				}
			}


			return false;
		}

	}
}

