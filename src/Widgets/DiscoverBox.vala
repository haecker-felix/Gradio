using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-box.ui")]
	public class DiscoverBox : Gtk.Box{

		GradioApp app;
		Library lib;
		DataProvider provider;

		[GtkChild]
		private ListBox ResultsBox;
		[GtkChild]
		private SearchEntry SearchEntry;
		[GtkChild]
		private Stack SearchStack;
		[GtkChild]
		private Button SearchButton;

		public DiscoverBox(ref GradioApp a, ref Library l){
			app = a;
			lib = l;
			provider = new Gradio.DataProvider(ref app);

			provider.status_changed.connect(() => {
				if(provider.isWorking){
					SearchButton.set_sensitive(false);
					SearchStack.set_visible_child_name("loading");
				}else{
					SearchButton.set_sensitive(true);
					SearchStack.set_visible_child_name("no_results");
				}				

			});

		}

		[GtkCallback]
		private void SearchButton_clicked(){
			string address = DataProvider.radio_stations + DataProvider.by_name + SearchEntry.get_text();

			provider.get_radio_stations.begin(address, 20, (obj, res) => {
		    		try {
		        		var search_results = provider.get_radio_stations.end(res);
		        		build_result_list(search_results);
		    		} catch (ThreadError e) {
		        		string msg = e.message;
		        		stderr.printf("Error: Thread:" + msg+ "\n");
		    		}
        		});
		}

		[GtkCallback]
		private void RecentlyButton_clicked(){
		}

		[GtkCallback]
		private void ClicksButton_clicked(){

		}

		[GtkCallback]
		private void VotesButton_clicked(){

		}

		private void build_result_list(ArrayList<RadioStation> stations){
			Util.remove_all_widgets(ref ResultsBox);

			if(stations != null){
				if(SearchEntry.get_text() != "" && !(stations.is_empty)){
					foreach (RadioStation station in stations) {
						ListItem box = new ListItem(ref app, ref lib, station);
						if(station.Available){
							ResultsBox.add(box);
						}else if(!app.settings.get_boolean("only-show-working-stations")){
							ResultsBox.add(box);
						}
					}
					SearchStack.set_visible_child_name("results");
					SearchButton.set_sensitive(true);
				}
			}


		}
	}
}
