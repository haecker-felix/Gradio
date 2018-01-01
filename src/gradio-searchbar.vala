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
using Gd;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/searchbar.ui")]
	public class SearchBar : Gtk.Box{

		private TaggedEntry SearchEntry;
		private string search_term = "";
		[GtkChild] private Box SearchBox;

		[GtkChild] private Stack CountryStack;
		[GtkChild] private Button SelectCountryButton;
		[GtkChild] private Button ClearCountryButton;
		[GtkChild] private Button ApplyCountryButton;
		[GtkChild] private Entry CountryEntry;
		private Gtk.EntryCompletion country_completion = new Gtk.EntryCompletion();
		private string selected_country = "";
		private TaggedEntryTag country_tag;

                [GtkChild] private Stack StateStack;
		[GtkChild] private Button SelectStateButton;
		[GtkChild] private Button ClearStateButton;
		[GtkChild] private Button ApplyStateButton;
		[GtkChild] private Entry StateEntry;
                private Gtk.EntryCompletion state_completion = new Gtk.EntryCompletion();
		private string selected_state = "";
		private TaggedEntryTag state_tag;

                [GtkChild] private Stack LanguageStack;
		[GtkChild] private Button SelectLanguageButton;
		[GtkChild] private Button ClearLanguageButton;
		[GtkChild] private Button ApplyLanguageButton;
		[GtkChild] private Entry LanguageEntry;
		private Gtk.EntryCompletion language_completion = new Gtk.EntryCompletion();
		private string selected_language = "";
		private TaggedEntryTag language_tag;

                [GtkChild] private Stack TagStack;
		[GtkChild] private Button SelectTagButton;
		[GtkChild] private Button ClearTagButton;
		[GtkChild] private Button ApplyTagButton;
		[GtkChild] private Entry TagEntry;
                private Gtk.EntryCompletion tag_completion = new Gtk.EntryCompletion();
		private string selected_tag = "";
		private TaggedEntryTag tag_tag;

		private CategoryItems category_items;
		private StationProvider station_provider;

		public signal void timeout_reset();
		private const int search_delay = 2;
		private uint delayed_changed_id;

		[GtkChild] private Label SortLabel;
		[GtkChild] public Button BackButton;

		private GLib.SimpleActionGroup search_action_group;
		public signal void show_search_results();

		public SearchBar(ref StationProvider sp){
			station_provider = sp;

			SearchEntry = new TaggedEntry();
			SearchEntry.set_visible(true);
			SearchEntry.set_placeholder_text(_("Search for radio stations"));
			SearchBox.pack_start(SearchEntry);

			tag_tag = new TaggedEntryTag("");
			country_tag = new TaggedEntryTag("");
			state_tag = new TaggedEntryTag("");
			language_tag = new TaggedEntryTag("");

			category_items = new CategoryItems();

                        country_completion.set_model(category_items.countries_model);
                        country_completion.set_text_column(0);
                        country_completion.set_minimum_key_length(0);
                        CountryEntry.set_completion(country_completion);

                        state_completion.set_model(category_items.states_model);
                        state_completion.set_text_column(0);
                        state_completion.set_minimum_key_length(0);
                        StateEntry.set_completion(state_completion);

                        language_completion.set_model(category_items.languages_model);
                        language_completion.set_text_column(0);
                        language_completion.set_minimum_key_length(0);
                        LanguageEntry.set_completion(language_completion);

                        tag_completion.set_model(category_items.tags_model);
                        tag_completion.set_text_column(0);
                        tag_completion.set_minimum_key_length(0);
                        TagEntry.set_completion(tag_completion);

			setup_actions();
			reset_timeout();
			connect_signals();
		}

		private void connect_signals(){
			SearchEntry.tag_button_clicked.connect((t,a) => {
				if(a == language_tag) clear_selected_language();
				if(a == country_tag) clear_selected_country();
				if(a == state_tag) clear_selected_state();
				if(a == tag_tag) clear_selected_tag();
			});

			CountryEntry.activate.connect(() => { set_country(); });
                        ApplyCountryButton.clicked.connect(() => { set_country(); });
                        SelectCountryButton.clicked.connect(() => { reset_view(); CountryStack.set_visible_child_name("entry"); });
                        ClearCountryButton.clicked.connect(() => { clear_selected_country(); });

                        StateEntry.activate.connect(() => { set_state(); });
                        ApplyStateButton.clicked.connect(() => { set_state(); });
                        SelectStateButton.clicked.connect(() => { reset_view(); StateStack.set_visible_child_name("entry"); });
                        ClearStateButton.clicked.connect(() => { clear_selected_state(); });

                        LanguageEntry.activate.connect(() => { set_language(); });
                        ApplyLanguageButton.clicked.connect(() => { set_language(); });
                        SelectLanguageButton.clicked.connect(() => { reset_view(); LanguageStack.set_visible_child_name("entry"); });
                        ClearLanguageButton.clicked.connect(() => { clear_selected_language(); });

                        TagEntry.activate.connect(() => { set_tag(); });
                        ApplyTagButton.clicked.connect(() => { set_tag(); });
                        SelectTagButton.clicked.connect(() => { reset_view(); TagStack.set_visible_child_name("entry"); });
                        ClearTagButton.clicked.connect(() => { clear_selected_tag(); });

			SearchEntry.search_changed.connect(() => {
				search_term = SearchEntry.get_text();
				reset_timeout();
				show_search_results();
			});

			App.settings.notify["station-sorting"].connect(reset_timeout);
			App.settings.notify["sort-ascending"].connect(reset_timeout);
		}

		private void setup_actions(){
			search_action_group = new GLib.SimpleActionGroup ();
			this.insert_action_group ("search", search_action_group);

			// Sorting
			var variant = new GLib.Variant.string(Util.get_sort_string());
			var action = new SimpleAction.stateful("sort", variant.get_type(), variant);
			action.activate.connect((a,b) => {
				set_sort(b.get_string(),(search_action_group.get_action_state("sortorder")).get_string());
				a.set_state(b);
			});
			search_action_group.add_action(action);


			// Order
			variant = new GLib.Variant.string(Util.get_sortorder_string());
			action = new SimpleAction.stateful("sortorder", variant.get_type(), variant);
			action.activate.connect((a,b) => {
				set_sort((search_action_group.get_action_state("sort")).get_string(), b.get_string());
				a.set_state(b);
			});
			search_action_group.add_action(action);

			set_sort((search_action_group.get_action_state("sort")).get_string(), (search_action_group.get_action_state("sortorder")).get_string());
		}

		public void set_sort(string sort_by, string order){
			string sortlabel = "";
			string orderlabel = "";

			switch(sort_by){
				case "votes": App.settings.station_sorting = Compare.VOTES; sortlabel = _("Votes"); break;
				case "name": App.settings.station_sorting = Compare.NAME; sortlabel = _("Name"); break;
				case "language": App.settings.station_sorting = Compare.LANGUAGE; sortlabel = _("Language"); break;
				case "country": App.settings.station_sorting = Compare.COUNTRY; sortlabel = _("Country"); break;
				case "state": App.settings.station_sorting = Compare.STATE; sortlabel = _("State"); break;
				case "bitrate": App.settings.station_sorting = Compare.BITRATE; sortlabel = _("Bitrate"); break;
				case "clickcount": App.settings.station_sorting = Compare.CLICKS; sortlabel = _("Clicks"); break;
				case "clicktimestamp": App.settings.station_sorting = Compare.DATE; sortlabel = _("Date"); break;
			}
			switch(order){
				case "ascending": App.settings.sort_ascending = true; orderlabel = _("Ascending"); break;
				case "descending": App.settings.sort_ascending = false; orderlabel = _("Descending"); break;
			}

			SortLabel.set_markup(_("<b>Sorting:</b> %s / %s").printf(sortlabel, orderlabel));
		}

		private void reset_timeout(){
			timeout_reset();

			if(delayed_changed_id > 0)
				Source.remove(delayed_changed_id);
			delayed_changed_id = Timeout.add_seconds(search_delay, timeout);
		}

		private bool timeout(){
			message("Sending new search request to server");

			HashTable<string, string> filter_table = new HashTable<string, string> (str_hash, str_equal);

			if(selected_language != null) filter_table.insert("language", selected_language);
			if(selected_country != null) filter_table.insert("country", selected_country);
			if(selected_state != null) filter_table.insert("state", selected_state);
			if(selected_tag != null) filter_table.insert("tag", selected_tag);
			if(search_term != null) filter_table.insert("name", search_term);

			filter_table.insert("order", Util.get_sort_string());
			filter_table.insert("reverse", (!App.settings.sort_ascending).to_string());
			filter_table.insert("limit", App.settings.max_search_results.to_string());

			station_provider.get_stations.begin(RadioBrowser.radio_station_search, filter_table);

			delayed_changed_id = 0;
			return false;
		}

		public void set_search(string term){
			search_term = term;
			SearchEntry.set_text(term);
			SearchEntry.set_position(-1);
		}

		public void reset_filters(){
			clear_selected_language();
			clear_selected_country();
			clear_selected_state();
                        clear_selected_tag();
			SearchEntry.set_text("");
		}

		private void reset_view(){
			CountryStack.set_visible_child_name("main");
			StateStack.set_visible_child_name("main");
			LanguageStack.set_visible_child_name("main");
                        TagStack.set_visible_child_name("main");
		}

		private void set_country(){
		        unowned string name;
                        name = CountryEntry.get_text();

                        if(name != ""){
                                SelectCountryButton.set_label(name);

                                selected_country = name;
                                country_tag.set_label(name);
                                SearchEntry.add_tag(country_tag);

                                ClearCountryButton.set_visible(true);
                                reset_timeout();
                                show_search_results();
                        }

                        CountryStack.set_visible_child_name("main");
		}

		private void clear_selected_country(){
			selected_country = "";
			country_tag.set_label("");
			SearchEntry.remove_tag(country_tag);
			SelectCountryButton.set_label(_("Select Country …"));
			CountryEntry.set_text("");
			ClearCountryButton.set_visible(false);
			SelectCountryButton.set_sensitive(true);

			reset_timeout();
		}

                private void set_state(){
		        unowned string name;
                        name = StateEntry.get_text();

                        if(name != ""){
                                SelectStateButton.set_label(name);

                                selected_state = name;
                                state_tag.set_label(name);
                                SearchEntry.add_tag(state_tag);

                                ClearStateButton.set_visible(true);
                                reset_timeout();
                                show_search_results();
                        }

                        StateStack.set_visible_child_name("main");
		}

		private void clear_selected_state(){
			selected_state = "";
			state_tag.set_label("");
			SearchEntry.remove_tag(state_tag);
			SelectStateButton.set_label(_("Select State …"));
			StateEntry.set_text("");
			ClearStateButton.set_visible(false);
			SelectStateButton.set_sensitive(true);

			reset_timeout();
		}

		private void set_language(){
		        unowned string name;
                        name = LanguageEntry.get_text();

                        if(name != ""){
                                SelectLanguageButton.set_label(name);

                                selected_language = name;
                                language_tag.set_label(name);
                                SearchEntry.add_tag(language_tag);

                                ClearLanguageButton.set_visible(true);
                                reset_timeout();
                                show_search_results();
                        }

                        LanguageStack.set_visible_child_name("main");
		}

		private void clear_selected_language(){
			selected_language = "";
			language_tag.set_label("");
			SearchEntry.remove_tag(language_tag);
			SelectLanguageButton.set_label(_("Select Language …"));
			LanguageEntry.set_text("");
			ClearLanguageButton.set_visible(false);
			SelectLanguageButton.set_sensitive(true);

			reset_timeout();
		}

		private void set_tag(){
		        unowned string name;
                        name = TagEntry.get_text();

                        if(name != ""){
                                SelectTagButton.set_label(name);

                                selected_tag = name;
                                tag_tag.set_label(name);
                                SearchEntry.add_tag(tag_tag);

                                ClearTagButton.set_visible(true);
                                reset_timeout();
                                show_search_results();
                        }

                        TagStack.set_visible_child_name("main");
		}

		private void clear_selected_tag(){
			selected_tag = "";
			tag_tag.set_label("");
			SearchEntry.remove_tag(tag_tag);
			SelectTagButton.set_label(_("Select Tag …"));
			TagEntry.set_text("");
			ClearTagButton.set_visible(false);
			SelectTagButton.set_sensitive(true);

			reset_timeout();
		}
	}
}
