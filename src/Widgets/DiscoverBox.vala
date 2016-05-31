using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		private GLib.Settings settings;

		private StationsListView list_view_search;
		private StationsGridView grid_view_search;

		[GtkChild]
		private Stack SearchStack;
		[GtkChild]
		private Box SearchBox;
		[GtkChild]
		private SearchEntry SearchEntry;
		[GtkChild]
		private Button SearchButton;

		public DiscoverBox(){
			settings = new GLib.Settings ("de.haecker-felix.gradio");

			list_view_search = new StationsListView();
			grid_view_search = new StationsGridView();

			SearchBox.add(grid_view_search);

			connect_signals();
		}
	
		private void connect_signals(){
			SearchEntry.activate.connect(() => SearchButton_clicked());

			App.data_provider.status_changed.connect(() => {
				if(App.data_provider.isWorking){
					SearchButton.set_sensitive(false);
					SearchStack.set_visible_child_name("loading");
				}else{
					SearchButton.set_sensitive(true);
					SearchStack.set_visible_child_name("results");
				}				
			});
		}


		[GtkCallback]
		private void SearchButton_clicked(){
			string address = StationDataProvider.radio_stations_by_name + Util.optimize_string(SearchEntry.get_text());

			App.data_provider.get_radio_stations.begin(address, 20, (obj, res) => {
		    		try {
		        		var search_results = App.data_provider.get_radio_stations.end(res);
		        		list_view_search.set_stations(ref search_results);
					grid_view_search.set_stations(ref search_results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		public void show_grid_view(){
			SearchBox.remove(list_view_search);
			SearchBox.add(grid_view_search);
			SearchBox.show_all();
		}

		public void show_list_view(){
			SearchBox.remove(grid_view_search);
			SearchBox.add(list_view_search);
			SearchBox.show_all();
		}
	}
}
