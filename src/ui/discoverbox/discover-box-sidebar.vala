/* This file is part of Gradio.
 *
 * Gradio is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gradio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gradio.  If not, see <http://www.gnu.org/licenses/>.
 */

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
			if(Settings.show_languages_c)
				CategoriesBox.pack_start(languages);
			languages.clicked.connect(() => {show_catergory_items("languages"); });

			SidebarTile codecs = new SidebarTile ("Codecs", "emblem-system-symbolic");
			if(Settings.show_codecs_c)
				CategoriesBox.pack_start(codecs);
			codecs.clicked.connect(() => {show_catergory_items("codecs"); });

			SidebarTile countries = new SidebarTile ("Countries", "mark-location-symbolic");
			if(Settings.show_countries_c)
				CategoriesBox.pack_start(countries);
			countries.clicked.connect(() => {show_catergory_items("countries"); });

			SidebarTile tags = new SidebarTile ("Tags", "dialog-information-symbolic");
			if(Settings.show_tags_c)
				CategoriesBox.pack_start(tags);
			tags.clicked.connect(() => {show_catergory_items("tags"); });

			SidebarTile states = new SidebarTile ("States", "mark-location-symbolic");
			if(Settings.show_states_c)
				CategoriesBox.pack_start(states);
			states.clicked.connect(() => {show_catergory_items("states"); });

			SidebarTile home = new SidebarTile ("Home", "go-home-symbolic");
			ActionBox.pack_end(home);
			home.clicked.connect(() => {dbox.show_home();});

			SidebarTile reload = new SidebarTile ("Reload", "view-refresh-symbolic");
			ActionBox.pack_end(reload);
			reload.clicked.connect(() => {dbox.reload();});

			SidebarTile add = new SidebarTile ("Create", "document-new-symbolic");
			ActionBox.pack_end(add);
			add.clicked.connect(() => {dbox.add_station();});

			show_categories();
		}

		private void connect_signals(){
			cip.loaded.connect(() => {
				Idle.add(() => {
					load_information.begin ((obj, res) => {
						load_information.end (res);
					});
					return false;
				});
			});


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

		private async void load_information (){
			message("Loading category items...");
			Util.remove_all_items_from_list_box((Gtk.ListBox) CodecItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) LanguageItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) CountryItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) StateItemsBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) TagItemsBox);

			foreach (string codec in cip.codecs_list){
				CategoriesRow box = new CategoriesRow(codec, codec, "");
				Idle.add(() => { CodecItemsBox.add(box); return false;});
			}
			foreach (string language in cip.languages_list){
				CategoriesRow box = new CategoriesRow(language, language, "");
				Idle.add(() => { LanguageItemsBox.add(box); return false;});
			}
			foreach (string tag in cip.tags_list){
				CategoriesRow box = new CategoriesRow(tag, tag, "");
				Idle.add(() => { TagItemsBox.add(box);; return false;});
			}
			foreach (string state in cip.states_list){
				CategoriesRow box = new CategoriesRow(state, state, "");
				Idle.add(() => { StateItemsBox.add(box); return false;});
			}
			foreach (string country in cip.countries_list){
				CategoriesRow box = new CategoriesRow(country, country, "");
				Idle.add(() => { CountryItemsBox.add(box); return false;});
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

			dbox.stations_view_results.set_title("Results for \"" + item + "\"");
			dbox.stations_view_results.set_stations_from_address(address);
			dbox.show_results();
			show_categories();
		}

		[GtkCallback]
		private void BackButton_clicked(Button button){
			show_categories();
		}
	}
}
