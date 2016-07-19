using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-sidebar.ui")]
	public class DiscoverSidebar : Gtk.Box{

		[GtkChild]
		private SearchEntry SearchEntry;
		[GtkChild]
		private Button SearchButton;
		[GtkChild]
		private ListBox CategoriesBox;
		[GtkChild]
		private ListBox ItemsBox;
		[GtkChild]
		private Stack SidebarStack;
		[GtkChild]
		private Button HomeButton;

		private DiscoverBox dbox;
		private string actual_view = "catergories";

		public DiscoverSidebar(DiscoverBox box){
			dbox = box;

			string css = "
				button, entry{
					background: linear-gradient(to right, transparent, alpha(red,0.3));
					border-radius: 0px;
					border: none;
				  }
			";

			Gtk.CssProvider provider = new Gtk.CssProvider();
			provider.load_from_data(css, css.length);
			SearchButton.get_style_context().add_provider(provider, 0);
			SearchEntry.get_style_context().add_provider(provider, 0);
			HomeButton.get_style_context().add_provider(provider, 0);

			CategoriesRow languages_row = new CategoriesRow("Languages", "languages","user-invisible-symbolic");
			CategoriesBox.add(languages_row);

			CategoriesRow countries_row = new CategoriesRow("Countries", "countries","help-about-symbolic");
			CategoriesBox.add(countries_row);

			CategoriesRow states_row = new CategoriesRow("States", "states","mark-location-symbolic");
			CategoriesBox.add(states_row);

			CategoriesRow codecs_row = new CategoriesRow("Codecs", "codecs","application-x-addon-symbolic");
			CategoriesBox.add(codecs_row);

			CategoriesRow tags_row = new CategoriesRow("Tags", "tags","dialog-information-symbolic");
			CategoriesBox.add(tags_row);

			SidebarStack.set_visible_child_name("catergories");
			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
			CategoriesBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;

				switch(item.action){
					case "languages": show_catergories_items("languages"); break;
					case "countries": show_catergories_items("countries"); break;
					case "states": show_catergories_items("states"); break;
					case "codecs": show_catergories_items("codecs"); break;
					case "tags": show_catergories_items("tags"); break;
				}
			});

			ItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;

				switch(actual_view){
					case "languages": {
						if(item.action != "back")
							show_stations_by_category_item("languages", item.action);
						else
							show_catergories_page();
						break;
					};
					case "countries": {
						if(item.action != "back")
							show_stations_by_category_item("countries", item.action);
						else
							show_catergories_page();
						break;
					};
					case "states": {
						if(item.action != "back")
							show_stations_by_category_item("states", item.action);
						else
							show_catergories_page();
						break;
					};
					case "codecs": {
						if(item.action != "back")
							show_stations_by_category_item("codecs", item.action);
						else
							show_catergories_page();
						break;
					};
					case "tags": {
						if(item.action != "back")
							show_stations_by_category_item("tags", item.action);
						else
							show_catergories_page();
						break;
					};
				}
			});
		}

		private void show_stations_by_category_item (string category, string item){
			if(!App.data_provider.isWorking){
				dbox.show_overview = false;
				string address = "";

				switch (category){
					case "languages": address = StationDataProvider.radio_stations_by_language + item; break;
					case "countries": address = StationDataProvider.radio_stations_by_country + item; break;
					case "states": address = StationDataProvider.radio_stations_by_state + item; break;
					case "codecs": address = StationDataProvider.radio_stations_by_codec + item; break;
					case "tags": address = StationDataProvider.radio_stations_by_tag + item; break;
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

		private void show_catergories_items (string category){

			Util.remove_all_items_from_list_box((Gtk.ListBox) ItemsBox);

			switch(category){
				case "languages": {
					actual_view = "languages";
					if(StationDataProvider.languages_list != null){
						CategoriesRow row = new CategoriesRow("Go back", "back", "go-previous-symbolic");
						ItemsBox.add(row);
						foreach (string language in StationDataProvider.languages_list){
							CategoriesRow box = new CategoriesRow(language, language, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "countries": {
					actual_view = "countries";
					if(StationDataProvider.languages_list != null){
						CategoriesRow row = new CategoriesRow("Go back", "back", "go-previous-symbolic");
						ItemsBox.add(row);
						foreach (string country in StationDataProvider.countries_list){
							CategoriesRow box = new CategoriesRow(country, country, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "states": {
					actual_view = "states";
					if(StationDataProvider.states_list != null){
						CategoriesRow row = new CategoriesRow("Go back", "back", "go-previous-symbolic");
						ItemsBox.add(row);
						foreach (string state in StationDataProvider.states_list){
							CategoriesRow box = new CategoriesRow(state, state, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "codecs": {
					actual_view = "codecs";
					if(StationDataProvider.codecs_list != null){
						CategoriesRow row = new CategoriesRow("Go back", "back", "go-previous-symbolic");
						ItemsBox.add(row);
						foreach (string codec in StationDataProvider.codecs_list){
							CategoriesRow box = new CategoriesRow(codec, codec, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
				case "tags": {
					actual_view = "tags";
					if(StationDataProvider.tags_list != null){
						CategoriesRow row = new CategoriesRow("Go back", "back", "go-previous-symbolic");
						ItemsBox.add(row);
						foreach (string tag in StationDataProvider.tags_list){
							CategoriesRow box = new CategoriesRow(tag, tag, "");
							ItemsBox.add(box);
						}
					}
					break;
				};
			}





			SidebarStack.set_visible_child_name("items");
		}



		[GtkCallback]
		private void HomeButton_clicked(Button button){
			show_catergories_page();
			dbox.show_overview_page();
		}

		private void show_catergories_page(){
			actual_view = "catergories";
			SidebarStack.set_visible_child_name("catergories");
		}

		[GtkCallback]
		private void SearchButton_clicked(){
			string address = StationDataProvider.radio_stations_by_name + Util.optimize_string(SearchEntry.get_text());

			if(!App.data_provider.isWorking){
				dbox.show_overview = false;
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


	}
}
