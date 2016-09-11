using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-sidebar.ui")]
	public class DiscoverSidebar : Gtk.Box{

		[GtkChild]
		private ScrolledWindow ItemsWindow;
		[GtkChild]
		private Box CategoriesBox;
		[GtkChild]
		private Box ActionBox;

		[GtkChild]
		private ListBox ItemsBox;

		private DiscoverBox dbox;
		private string actual_view;

		private CategoryItemProvider cip;

		public DiscoverSidebar(DiscoverBox box){
			dbox = box;

			SidebarTile languages = new SidebarTile ("Languages", "user-invisible-symbolic");
			CategoriesBox.pack_start(languages);
			languages.clicked.connect(() => {show_catergory_items("languages"); dbox.show_select_item();});

			SidebarTile codecs = new SidebarTile ("Codecs", "emblem-system-symbolic");
			CategoriesBox.pack_start(codecs);
			codecs.clicked.connect(() => {show_catergory_items("codecs"); dbox.show_select_item();});

			SidebarTile countries = new SidebarTile ("Countries", "mark-location-symbolic");
			CategoriesBox.pack_start(countries);
			countries.clicked.connect(() => {show_catergory_items("countries"); dbox.show_select_item();});

			SidebarTile tags = new SidebarTile ("Tags", "dialog-information-symbolic");
			CategoriesBox.pack_start(tags);
			tags.clicked.connect(() => {show_catergory_items("tags"); dbox.show_select_item();});

			SidebarTile states = new SidebarTile ("States", "mark-location-symbolic");
			CategoriesBox.pack_start(states);
			states.clicked.connect(() => {show_catergory_items("states"); dbox.show_select_item();});

			SidebarTile home = new SidebarTile ("Home", "go-home-symbolic");
			ActionBox.pack_end(home);
			home.clicked.connect(() => {dbox.show_home();});

			SidebarTile reload = new SidebarTile ("Reload", "emblem-synchronizing-symbolic");
			ActionBox.pack_end(reload);
			reload.clicked.connect(() => {dbox.reload();});

			SidebarTile add = new SidebarTile ("Create", "document-new-symbolic");
			ActionBox.pack_end(add);
			add.clicked.connect(() => {dbox.add_station();});

			cip = new CategoryItemProvider();

			show_categories();

			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
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

		public void show_categories(){
			ItemsWindow.set_visible(false);
		}

		private void show_items(){
			ItemsWindow.set_visible(true);
		}

		private void show_stations_by_category_item (string category, string item){
			string address = "";
			show_items();

			switch (category){
				case "languages": address = RadioBrowser.radio_stations_by_language + item; break;
				case "countries": address = RadioBrowser.radio_stations_by_country + item; break;
				case "states": address = RadioBrowser.radio_stations_by_state + item; break;
				case "codecs": address = RadioBrowser.radio_stations_by_codec + item; break;
				case "tags": address = RadioBrowser.radio_stations_by_tag + item; break;
			}

			dbox.show_results();
			dbox.stations_view_results.set_stations_from_address(address);
		}

		private void show_catergory_items (string category){
			Util.remove_all_items_from_list_box((Gtk.ListBox) ItemsBox);

			show_items();

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
