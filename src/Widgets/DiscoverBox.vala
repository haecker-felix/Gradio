using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		GradioApp app;
		public RadioStationsProvider provider;

		[GtkChild]
		private ListBox ResultsBox;
		[GtkChild]
		private SearchEntry SearchEntry;
		[GtkChild]
		private Stack SearchStack;


		public DiscoverBox(ref GradioApp a){
			app = a;
			provider = new Gradio.RadioStationsProvider(ref app);

			provider.status_changed.connect(() => {
				if(provider.isWorking){
					SearchStack.set_visible_child_name("loading");
				}else{
					SearchStack.set_visible_child_name("no_results");
				}
			});
		}

		[GtkCallback]
		private void SearchEntry_search_changed(){
			provider.search_radio_stations.begin(SearchEntry.get_text(), Search.BY_NAME, (obj, res) => {
		    		try {
		        		var search_results = provider.search_radio_stations.end(res);
		        		build_result_list(search_results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void RecentlyButton_clicked(){
			provider.search_radio_stations.begin(SearchEntry.get_text(), Search.BY_NAME, (obj, res) => {
		    		try {
		        		var search_results = provider.search_radio_stations.end(res);
		        		build_result_list(search_results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void ClicksButton_clicked(){
			provider.search_radio_stations.begin(SearchEntry.get_text(), Search.BY_NAME, (obj, res) => {
		    		try {
		        		var search_results = provider.search_radio_stations.end(res);
		        		build_result_list(search_results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void VotesButton_clicked(){
			provider.search_radio_stations.begin(SearchEntry.get_text(), Search.BY_NAME, (obj, res) => {
		    		try {
		        		var search_results = provider.search_radio_stations.end(res);
		        		build_result_list(search_results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		private void build_result_list(ArrayList<RadioStation> stations){
			Util.remove_all_widgets(ref ResultsBox);
			print("NR 1 HÄÄÄÄÄÄÄÄÄÄÄ?\n");

			if(stations != null){
				print("NR 2 HÄÄÄÄÄÄÄÄÄÄÄ?\n");
				if(SearchEntry.get_text() != "" && !(stations.is_empty)){
					foreach (RadioStation station in stations) {
						print("added...");
						ListItem box = new ListItem(app, station);

						ResultsBox.add(box);
						SearchStack.set_visible_child_name("results");
					}
				}
			}


		}
	}
}
