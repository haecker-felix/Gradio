using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		DataProvider provider;
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
			provider = new Gradio.DataProvider();

			list_view_search = new StationsListView();
			grid_view_search = new StationsGridView();

			SearchBox.add(list_view_search);

			connect_signals();
		}
	
		private void connect_signals(){
			SearchEntry.activate.connect(() => SearchButton_clicked());

			provider.status_changed.connect(() => {
				if(provider.isWorking){
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
			string address = DataProvider.radio_stations + DataProvider.by_name + Util.optimize_string(SearchEntry.get_text());

			provider.get_radio_stations.begin(address, 20, (obj, res) => {
		    		try {
		        		var search_results = provider.get_radio_stations.end(res);
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
