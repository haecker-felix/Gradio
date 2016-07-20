using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		private GLib.Settings settings;

		public StationsView stations_view_results;
		public bool show_overview = true;

		private StationsView grid_view_recently_clicked;
		private StationsView grid_view_most_votes;
		private StationsView grid_view_recently_changed;

		private StationsViewButton button_recently_clicked;
		private StationsViewButton button_recently_changed;
		private StationsViewButton button_most_votes;

		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private FlowBox categories;
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
		[GtkChild]
		private SearchEntry SearchEntry;

		[GtkChild]
		private Button HomeButton;
		[GtkChild]
		private Button ReloadButton;
		[GtkChild]
		private Button SearchButton;

		private DiscoverSidebar sidebar;

		public signal void languages_clicked();
		public signal void countries_clicked();
		public signal void states_clicked();
		public signal void tags_clicked();
		public signal void codecs_clicked();


		public DiscoverBox(){
			settings = new GLib.Settings ("de.haecker-felix.gradio");

			stations_view_results = new StationsView("Results", true, "system-search-symbolic");

			grid_view_recently_changed = new StationsView("Recently Changed", false, "text-editor-symbolic");
			grid_view_recently_clicked = new StationsView("Recently Clicked", false, "view-refresh-symbolic");
			grid_view_most_votes = new StationsView("Most Popular", false, "emote-love-symbolic");

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

			CategoryTile languages = new CategoryTile ("Languages", "languages", "user-invisible-symbolic");
			categories.add(languages);

			CategoryTile codecs = new CategoryTile ("Codecs", "codecs", "application-x-addon-symbolic");
			categories.add(codecs);

			CategoryTile countries = new CategoryTile ("Countries", "countries", "help-about-symbolic");
			categories.add(countries);

			CategoryTile tags = new CategoryTile ("Tags", "tags", "dialog-information-symbolic");
			categories.add(tags);

			CategoryTile states = new CategoryTile ("States", "states", "mark-location-symbolic");
			categories.add(states);

			sidebar = new DiscoverSidebar(this);
			SidebarBox.pack_start(sidebar);
			sidebar.set_visible(false);

			connect_signals();
			load_data();
			ContentStack.set_visible_child_name("loading");
		}

		private void connect_signals(){
			App.data_provider.status_changed.connect(() => {
				if(App.data_provider.isWorking){
					HomeButton.set_sensitive(false);
					ReloadButton.set_sensitive(false);
					SearchButton.set_sensitive(false);
					SearchEntry.set_sensitive(false);
					ContentStack.set_visible_child_name("loading");
				}else{
					HomeButton.set_sensitive(true);
					ReloadButton.set_sensitive(true);
					SearchButton.set_sensitive(true);
					SearchEntry.set_sensitive(true);
					if(show_overview)
						ContentStack.set_visible_child_name("overview");
					else
						ContentStack.set_visible_child_name("results");
				}
			});

			categories.child_activated.connect((t,a) => {
				CategoryTile item = (CategoryTile)a;
				message("child_activated");
				switch(item.action){
					case "languages": languages_clicked(); ContentStack.set_visible_child_name("select-item"); sidebar.set_visible(true); break;
					case "countries": countries_clicked(); ContentStack.set_visible_child_name("select-item"); sidebar.set_visible(true); break;
					case "states": states_clicked(); ContentStack.set_visible_child_name("select-item"); sidebar.set_visible(true); break;
					case "codecs": codecs_clicked(); ContentStack.set_visible_child_name("select-item"); sidebar.set_visible(true); break;
					case "tags": tags_clicked(); ContentStack.set_visible_child_name("select-item"); sidebar.set_visible(true); break;
				}
			});

			button_recently_clicked.clicked.connect(() => show_recently_clicked());
			button_recently_changed.clicked.connect(() => show_recently_changed());
			button_most_votes.clicked.connect(() => show_most_votes());
		}

		public void show_overview_page(){
			ContentStack.set_visible_child_name("overview");
			show_overview = true;
			sidebar.set_visible(false);
		}

		private void load_data(){
			App.data_provider.get_radio_stations.begin(StationDataProvider.radio_stations_most_votes, 12, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		grid_view_most_votes.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});

        		App.data_provider.get_radio_stations.begin(StationDataProvider.radio_stations_recently_clicked, 12, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		grid_view_recently_clicked.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});

        		App.data_provider.get_radio_stations.begin(StationDataProvider.radio_stations_recently_changed, 12, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		grid_view_recently_changed.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});


		}

		private void show_recently_changed(){
			show_overview = false;
			App.data_provider.get_radio_stations.begin(StationDataProvider.radio_stations_recently_changed, 100, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		stations_view_results.set_stations(ref results);
					stations_view_results.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		private void show_recently_clicked(){
			show_overview = false;
			App.data_provider.get_radio_stations.begin(StationDataProvider.radio_stations_recently_clicked, 100, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		stations_view_results.set_stations(ref results);
					stations_view_results.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		private void show_most_votes(){
			show_overview = false;
			App.data_provider.get_radio_stations.begin(StationDataProvider.radio_stations_most_votes, 100, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		stations_view_results.set_stations(ref results);
					stations_view_results.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void SearchButton_clicked(){
			sidebar.set_visible(false);
			string address = StationDataProvider.radio_stations_by_name + Util.optimize_string(SearchEntry.get_text());

			if(!App.data_provider.isWorking){
				show_overview = false;
				App.data_provider.get_radio_stations.begin(address, 100, (obj, res) => {
			    		try {
						var search_results = App.data_provider.get_radio_stations.end(res);
						stations_view_results.set_stations(ref search_results);
						stations_view_results.set_stations(ref search_results);
			    		} catch (ThreadError e) {
						string msg = e.message;
						stderr.printf("Error: Thread:" + msg+ "\n");
			    		}
        			});
			}

		}

		[GtkCallback]
		private void HomeButton_clicked(Button button){
			sidebar.set_visible(false);
			show_overview_page();
		}

		[GtkCallback]
		private void ReloadButton_clicked(Button button){
			load_data();
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
