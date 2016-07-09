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

		private string search_by = StationDataProvider.radio_stations_by_name;
		private signal void search_by_changed();

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

			sidebar = new DiscoverSidebar(this);
			SidebarBox.pack_start(sidebar);

			connect_signals();
			load_data();
			ContentStack.set_visible_child_name("overview");
		}

		private void connect_signals(){
			App.data_provider.status_changed.connect(() => {
				if(App.data_provider.isWorking){
					ContentStack.set_visible_child_name("loading");
				}else{
					if(show_overview)
						ContentStack.set_visible_child_name("overview");
					else
						ContentStack.set_visible_child_name("results");
				}
			});

			button_recently_clicked.clicked.connect(() => show_recently_clicked());
			button_recently_changed.clicked.connect(() => show_recently_changed());
			button_most_votes.clicked.connect(() => show_most_votes());
		}

		public void show_overview_page(){
			ContentStack.set_visible_child_name("overview");
			show_overview = true;
		}

		private void load_data(){
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_most_votes, 9, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		grid_view_most_votes.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});

        		App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_recently_clicked, 9, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		grid_view_recently_clicked.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});

        		App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_recently_changed, 9, (obj, res) => {
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
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_recently_changed, 100, (obj, res) => {
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
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_recently_clicked, 100, (obj, res) => {
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
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_most_votes, 100, (obj, res) => {
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
