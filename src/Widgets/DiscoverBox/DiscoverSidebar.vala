using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-sidebar.ui")]
	public class DiscoverSidebar : Gtk.Box{

		[GtkChild]
		private ListBox ItemsBox;

		private DiscoverBox dbox;
		private string actual_view;

		private CategoryItemProvider cip;

		public DiscoverSidebar(DiscoverBox box){
			dbox = box;

			cip = new CategoryItemProvider();

			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
			dbox.languages_clicked.connect(() => show_catergory_items("languages"));
			dbox.countries_clicked.connect(() => show_catergory_items("countries"));
			dbox.states_clicked.connect(() => show_catergory_items("states"));
			dbox.codecs_clicked.connect(() => show_catergory_items("codecs"));
			dbox.tags_clicked.connect(() => show_catergory_items("tags"));

			ItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;

				switch(actual_view){
					case "languages": {
							show_stations_by_category_item("languages", item.action); break;
					};
					case "countries": {
							show_stations_by_category_item("countries", item.action); break;
					};
					case "states": {
							show_stations_by_category_item("states", item.action); break;
					};
					case "codecs": {
							show_stations_by_category_item("codecs", item.action); break;
					};
					case "tags": {
							show_stations_by_category_item("tags", item.action); break;
					};
				}
			});
		}

		private void show_stations_by_category_item (string category, string item){
			if(!App.data_provider.isWorking){
				dbox.show_overview = false;
				string address = "";

				switch (category){
					case "languages": address = RadioBrowser.radio_stations_by_language + item; break;
					case "countries": address = RadioBrowser.radio_stations_by_country + item; break;
					case "states": address = RadioBrowser.radio_stations_by_state + item; break;
					case "codecs": address = RadioBrowser.radio_stations_by_codec + item; break;
					case "tags": address = RadioBrowser.radio_stations_by_tag + item; break;
				}

				App.data_provider.get_radio_stations.begin(address, 100, (obj, res) => {
			    		try {
						var search_results = App.data_provider.get_radio_stations.end(res);
						dbox.stations_view_results.set_stations(ref search_results);
						dbox.stations_view_results.set_stations(ref search_results);
			    		} catch (ThreadError e) {
						string msg = e.message;
						stderr.printf("Error: Thread:" + msg+ "\n");
			    		}
        			});
			}
		}

		private void show_catergory_items (string category){

			Util.remove_all_items_from_list_box((Gtk.ListBox) ItemsBox);

			switch(category){
				case "languages": {
					actual_view = "languages";
					if(cip.languages_list != null){
						foreach (string language in cip.languages_list){
							CategoriesRow box = new CategoriesRow(language, language, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "countries": {
					actual_view = "countries";
					if(cip.languages_list != null){
						foreach (string country in cip.countries_list){
							CategoriesRow box = new CategoriesRow(country, country, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "states": {
					actual_view = "states";
					if(cip.states_list != null){
						foreach (string state in cip.states_list){
							CategoriesRow box = new CategoriesRow(state, state, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "codecs": {
					actual_view = "codecs";
					if(cip.codecs_list != null){
						foreach (string codec in cip.codecs_list){
							CategoriesRow box = new CategoriesRow(codec, codec, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "tags": {
					actual_view = "tags";
					if(cip.tags_list != null){
						foreach (string tag in cip.tags_list){
							CategoriesRow box = new CategoriesRow(tag, tag, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
			}
		}

	}
}
