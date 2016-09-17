using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-sidebar.ui")]
	public class DiscoverSidebar : Gtk.Box{

		[GtkChild]
		private Box CategoriesBox;
		[GtkChild]
		private Box ActionBox;
		[GtkChild]
		private Revealer ItemsBox;

		[GtkChild]
		private ListBox LanguageItemsBox;
		[GtkChild]
		private ListBox CountryItemsBox;
		[GtkChild]
		private ListBox StateItemsBox;
		[GtkChild]
		private ListBox CodecItemsBox;
		[GtkChild]
		private ListBox TagItemsBox;

		[GtkChild]
		private Stack Items;

		private DiscoverBox dbox;

		private CategoryItemProvider cip;

		public DiscoverSidebar(DiscoverBox box){
			dbox = box;
			cip = new CategoryItemProvider();

			setup_view();
			connect_signals();

			this.show_all();
		}

		private void setup_view(){
			SidebarTile languages = new SidebarTile ("Languages", "user-invisible-symbolic");
			CategoriesBox.pack_start(languages);
			languages.clicked.connect(() => {show_catergory_items("languages"); });

			SidebarTile codecs = new SidebarTile ("Codecs", "emblem-system-symbolic");
			CategoriesBox.pack_start(codecs);
			codecs.clicked.connect(() => {show_catergory_items("codecs"); });

			SidebarTile countries = new SidebarTile ("Countries", "mark-location-symbolic");
			CategoriesBox.pack_start(countries);
			countries.clicked.connect(() => {show_catergory_items("countries"); });

			SidebarTile tags = new SidebarTile ("Tags", "dialog-information-symbolic");
			CategoriesBox.pack_start(tags);
			tags.clicked.connect(() => {show_catergory_items("tags"); });

			SidebarTile states = new SidebarTile ("States", "mark-location-symbolic");
			CategoriesBox.pack_start(states);
			states.clicked.connect(() => {show_catergory_items("states"); });

			SidebarTile home = new SidebarTile ("Home", "go-home-symbolic");
			ActionBox.pack_end(home);
			home.clicked.connect(() => {dbox.show_home();});

			SidebarTile reload = new SidebarTile ("Reload", "emblem-synchronzing-symbolic");
			ActionBox.pack_end(reload);
			reload.clicked.connect(() => {dbox.reload();});

			SidebarTile add = new SidebarTile ("Create", "document-new-symbolic");
			ActionBox.pack_end(add);
			add.clicked.connect(() => {dbox.add_station();});

			show_categories();
		}

		private void connect_signals(){
			cip.loaded.connect(() => load_information());

			LanguageItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;
				show_stations_by_category_item("languages", item.action);
			});
			CountryItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;
				show_stations_by_category_item("countries", item.action);
			});
			StateItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;
				show_stations_by_category_item("states", item.action);
			});
			CodecItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;
				show_stations_by_category_item("codecs", item.action);
			});
			TagItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;
				show_stations_by_category_item("tags", item.action);
			});
		}

		private void load_information(){
			message("Loading category items...");
			Util.remove_all_items_from_list_box((Gtk.ListBox) CodecItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) LanguageItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) CountryItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) StateItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) TagItemsBox);

			foreach (string codec in cip.codecs_list){
				CategoriesRow box = new CategoriesRow(codec, codec, "");
				CodecItemsBox.add(box);
			}
			foreach (string language in cip.languages_list){
				CategoriesRow box = new CategoriesRow(language, language, "");
				LanguageItemsBox.add(box);
			}
			foreach (string tag in cip.tags_list){
				CategoriesRow box = new CategoriesRow(tag, tag, "");
				TagItemsBox.add(box);
			}
			foreach (string state in cip.states_list){
				CategoriesRow box = new CategoriesRow(state, state, "");
				StateItemsBox.add(box);
			}
			foreach (string country in cip.countries_list){
				CategoriesRow box = new CategoriesRow(country, country, "");
				CountryItemsBox.add(box);
			}
		}

		public void show_categories(){
			ItemsBox.set_reveal_child(false);
		}

		private void show_items(){
			ItemsBox.set_reveal_child(true);
		}

		private void show_catergory_items (string category){
			show_items();

			switch(category){
				case "languages": {
					Items.set_visible_child_name("languages"); break;
				};
				case "countries": {
					Items.set_visible_child_name("countries"); break;
				};
				case "states": {
					Items.set_visible_child_name("states"); break;
				};
				case "codecs": {
					Items.set_visible_child_name("codecs"); break;
				};
				case "tags": {
					Items.set_visible_child_name("tags"); break;
				};
			}
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
			show_categories();
		}
	}
}
