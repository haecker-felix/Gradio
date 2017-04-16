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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/search-popover.ui")]
	public class SearchPopover : Gtk.Popover{

		[GtkChild] private Revealer CountryRevealer;
		[GtkChild] private Button SelectCountryButton;
		[GtkChild] private Button ClearCountryButton;
		[GtkChild] private ListBox CountryListBox;
		private TaggedEntryTag country_tag;

		[GtkChild] private Revealer StateRevealer;
		[GtkChild] private Button SelectStateButton;
		[GtkChild] private Button ClearStateButton;
		[GtkChild] private ListBox StateListBox;
		private TaggedEntryTag state_tag;

		[GtkChild] private Revealer LanguageRevealer;
		[GtkChild] private Button SelectLanguageButton;
		[GtkChild] private Button ClearLanguageButton;
		[GtkChild] private ListBox LanguageListBox;
		private TaggedEntryTag language_tag;

		private TaggedEntry searchbar;

		public signal void changed();

		public SearchPopover(ref Gd.TaggedEntry entry){
			searchbar = entry;

			country_tag = new TaggedEntryTag("");
			state_tag = new TaggedEntryTag("");
			language_tag = new TaggedEntryTag("");

			connect_signals();
		}

		private void connect_signals(){
			if(!App.ciprovider.is_ready){
				App.ciprovider.loaded.connect(fill_lists);
			}else{
				fill_lists();
			}

			searchbar.tag_button_clicked.connect((t,tag) => {
				if(tag == country_tag)
					clear_country_tag();
				if(tag == state_tag)
					clear_state_tag();
				if(tag == language_tag)
					clear_language_tag();
			});

			CountryListBox.row_activated.connect((t,a) => {
				string selected_item = ((Label) a.get_child()).get_text();
				SelectCountryButton.set_label(selected_item);

				country_tag.set_label(selected_item);
				searchbar.add_tag(country_tag);

				CountryRevealer.set_reveal_child(false);
				ClearCountryButton.set_visible(true);
			});

			StateListBox.row_activated.connect((t,a) => {
				string selected_item = ((Label) a.get_child()).get_text();
				SelectStateButton.set_label(selected_item);

				state_tag.set_label(selected_item);
				searchbar.add_tag(state_tag);

				StateRevealer.set_reveal_child(false);
				ClearStateButton.set_visible(true);
			});

			LanguageListBox.row_activated.connect((t,a) => {
				string selected_item = ((Label) a.get_child()).get_text();
				SelectLanguageButton.set_label(selected_item);

				language_tag.set_label(selected_item);
				searchbar.add_tag(language_tag);

				LanguageRevealer.set_reveal_child(false);
				ClearLanguageButton.set_visible(true);
			});

		}

		private void fill_lists(){
			App.ciprovider.countries_list.foreach ((s) => {
				Label l = new Label (s);
				l.set_halign(Align.START);
				l.set_visible(true);
				CountryListBox.add(l);
			});

			App.ciprovider.states_list.foreach ((s) => {
				Label l = new Label (s);
				l.set_halign(Align.START);
				l.set_visible(true);
				StateListBox.add(l);
			});

			App.ciprovider.languages_list.foreach ((s) => {
				Label l = new Label (s);
				l.set_halign(Align.START);
				l.set_visible(true);
				LanguageListBox.add(l);
			});
		}

		private void unreveal_all(){
			CountryRevealer.set_reveal_child(false);
			StateRevealer.set_reveal_child(false);
			LanguageRevealer.set_reveal_child(false);
		}

		private void clear_country_tag(){
			searchbar.remove_tag(country_tag);
			country_tag.set_label("");
			SelectCountryButton.set_label("Select Country ...");
			ClearCountryButton.set_visible(false);
		}

		[GtkCallback]
		private void SelectCountryButton_clicked(Button button){
			unreveal_all();
			CountryRevealer.set_reveal_child(!CountryRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearCountryButton_clicked(Button button){
			clear_country_tag();
		}

		private void clear_state_tag(){
			searchbar.remove_tag(state_tag);
			state_tag.set_label("");
			SelectStateButton.set_label("Select State ...");
			ClearStateButton.set_visible(false);
		}

		[GtkCallback]
		private void SelectStateButton_clicked(Button button){
			unreveal_all();
			StateRevealer.set_reveal_child(!StateRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearStateButton_clicked(Button button){
			clear_state_tag();
		}

		private void clear_language_tag(){
			searchbar.remove_tag(language_tag);
			language_tag.set_label("");
			SelectLanguageButton.set_label("Select Language ...");
			ClearLanguageButton.set_visible(false);
		}

		[GtkCallback]
		private void SelectLanguageButton_clicked(Button button){
			unreveal_all();
			LanguageRevealer.set_reveal_child(!LanguageRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearLanguageButton_clicked(Button button){
			clear_language_tag();
		}
	}
}
