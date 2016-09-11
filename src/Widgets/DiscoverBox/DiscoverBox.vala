using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		private GLib.Settings settings;

		public StationsView stations_view_results;

		private StationsView grid_view_recently_clicked;
		private StationsView grid_view_most_votes;
		private StationsView grid_view_recently_changed;

		private StationsViewButton button_recently_clicked;
		private StationsViewButton button_recently_changed;
		private StationsViewButton button_most_votes;

		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private Stack ContentStack;

		[GtkChild]
		private Box most_votes;
		[GtkChild]
		private Box recently_changed;
		[GtkChild]
		private Box recently_clicked;
		[GtkChild]
		private Box SidebarBox;

		private DiscoverSidebar sidebar;

		public DiscoverBox(){
			settings = new GLib.Settings ("de.haecker-felix.gradio");

			stations_view_results = new StationsView("Results", "system-search-symbolic");
			grid_view_recently_changed = new StationsView("Recently Changed", "text-editor-symbolic", true);
			grid_view_recently_clicked = new StationsView("Recently Clicked", "view-refresh-symbolic", true);
			grid_view_most_votes = new StationsView("Most Popular", "emote-love-symbolic", true);

			grid_view_recently_changed.clicked.connect((t) => Gradio.App.player.set_radio_station(t));
			grid_view_recently_clicked.clicked.connect((t) => Gradio.App.player.set_radio_station(t));
			grid_view_most_votes.clicked.connect((t) => Gradio.App.player.set_radio_station(t));
			stations_view_results.clicked.connect((t) => Gradio.App.player.set_radio_station(t));

			button_most_votes = new StationsViewButton();
			button_recently_changed = new StationsViewButton();
			button_recently_clicked = new StationsViewButton();

			grid_view_recently_changed.set_extra_item(button_recently_changed);
			grid_view_recently_clicked.set_extra_item(button_recently_clicked);
			grid_view_most_votes.set_extra_item(button_most_votes);

			most_votes.add(grid_view_most_votes);
			recently_changed.add(grid_view_recently_changed);
			recently_clicked.add(grid_view_recently_clicked);

			SearchBox.add(stations_view_results);

			sidebar = new DiscoverSidebar(this);
			SidebarBox.pack_start(sidebar);

			connect_signals();
			load_data();
			show_overview_page();
		}

		private void connect_signals(){
			button_recently_clicked.clicked.connect(() => show_recently_clicked());
			button_recently_changed.clicked.connect(() => show_recently_changed());
			button_most_votes.clicked.connect(() => show_most_votes());
		}

		public void show_select_item(){
			ContentStack.set_visible_child_name("select-item");
		}

		public void show_results(){
			ContentStack.set_visible_child_name("results");
		}

		public void show_overview_page(){
			ContentStack.set_visible_child_name("overview");
			sidebar.show_categories();
		}

		private void load_data(){
			grid_view_most_votes.set_stations_from_address(RadioBrowser.radio_stations_most_votes);
			grid_view_recently_clicked.set_stations_from_address(RadioBrowser.radio_stations_recently_clicked);
			grid_view_recently_changed.set_stations_from_address(RadioBrowser.radio_stations_recently_changed);
		}

		private void show_recently_changed(){
			stations_view_results.set_stations_from_address(RadioBrowser.radio_stations_recently_changed);
			show_results();
		}

		private void show_recently_clicked(){
			stations_view_results.set_stations_from_address(RadioBrowser.radio_stations_recently_clicked);
			show_results();
		}

		private void show_most_votes(){
			stations_view_results.set_stations_from_address(RadioBrowser.radio_stations_most_votes);
			show_results();
		}

		public void SearchButton_clicked(string search){
			show_results();
			sidebar.show_categories();
			string address = RadioBrowser.radio_stations_by_name + Util.optimize_string(search);
			stations_view_results.set_stations_from_address(address);

		}

		public void show_home(){
			sidebar.show_categories();

			show_overview_page();
		}

		public void reload(){
			load_data();
		}

		public void add_station(){
			Util.open_website("http://www.radio-browser.info");
		}

		// Switch
		public void show_grid_view(){
			stations_view_results.show_grid_view();
			grid_view_recently_clicked.show_grid_view();
			grid_view_recently_changed.show_grid_view();
			grid_view_most_votes.show_grid_view();
		}
		public void show_list_view(){
			stations_view_results.show_list_view();
			grid_view_recently_clicked.show_list_view();
			grid_view_recently_changed.show_list_view();
			grid_view_most_votes.show_list_view();
		}
	}
}
