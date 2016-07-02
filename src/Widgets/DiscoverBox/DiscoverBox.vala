using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		private GLib.Settings settings;

		public StationsListView list_view_results;
		public StationsGridView grid_view_results;
		public bool show_overview = true;

		private StationsGridView grid_view_recently_clicked;
		private StationsGridView grid_view_most_votes;
		private StationsGridView grid_view_recently_changed;

		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private Stack ContentStack;

		[GtkChild]
		private Paned DiscoverPaned;

		[GtkChild]
		private Box most_votes;
		[GtkChild]
		private Box recently_changed;
		[GtkChild]
		private Box recently_clicked;

		private DiscoverSidebar sidebar;

		private string search_by = StationDataProvider.radio_stations_by_name;
		private signal void search_by_changed();

		public DiscoverBox(){
			settings = new GLib.Settings ("de.haecker-felix.gradio");

			list_view_results = new StationsListView();
			grid_view_results = new StationsGridView();

			grid_view_recently_changed = new StationsGridView();
			grid_view_recently_clicked = new StationsGridView();
			grid_view_most_votes = new StationsGridView();

			most_votes.add(grid_view_most_votes);
			recently_changed.add(grid_view_recently_changed);
			recently_clicked.add(grid_view_recently_clicked);

			SearchBox.add(grid_view_results);

			sidebar = new DiscoverSidebar(this);
			DiscoverPaned.add(sidebar);

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



		[GtkCallback]
		private void RecentlyChangedButton_clicked(){
			show_overview = false;
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_recently_changed, 100, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		list_view_results.set_stations(ref results);
					grid_view_results.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void RecentlyClickedButton_clicked(){
			show_overview = false;
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_recently_clicked, 100, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		list_view_results.set_stations(ref results);
					grid_view_results.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void MostVotesButton_clicked(){
			show_overview = false;
			App.data_provider.get_radio_stations.begin(App.data_provider.radio_stations_most_votes, 100, (obj, res) => {
		    		try {
		        		var results = App.data_provider.get_radio_stations.end(res);
		        		list_view_results.set_stations(ref results);
					grid_view_results.set_stations(ref results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		//[GtkCallback]
		//private void HomeButton_clicked(){
		//	ContentStack.set_visible_child_name("overview");
		//	show_overview = true;
		//}



		// Switch
		public void show_grid_view(){
			//SearchBox.remove(list_view_search);
			//SearchBox.add(grid_view_search);
			//SearchBox.show_all();
		}
		public void show_list_view(){
			//SearchBox.remove(grid_view_search);
			//SearchBox.add(list_view_search);
			//SearchBox.show_all();
		}
	}
}
