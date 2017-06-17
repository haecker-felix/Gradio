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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/filter-box.ui")]
	public class FilterBox : Gtk.Box{

		[GtkChild] private SearchEntry SearchEntry;
		public string search_term;

		[GtkChild] private RadioButton VotesRButton;
		[GtkChild] private RadioButton NameRButton;
		[GtkChild] private RadioButton LanguageRButton;
		[GtkChild] private RadioButton CountryRButton;
		[GtkChild] private RadioButton StateRButton;
		[GtkChild] private RadioButton BitrateRButton;
		[GtkChild] private RadioButton ClicksRButton;
		[GtkChild] private RadioButton ClickTimestampRButton;
		public string sort_by = "votes";

		[GtkChild] private ToggleButton SortDescendingButton;
		[GtkChild] private ToggleButton SortAscendingButton;
		public bool sort_descending = false;


		[GtkChild] private Revealer CountryRevealer;
		[GtkChild] private Button SelectCountryButton;
		[GtkChild] private Button ClearCountryButton;
		[GtkChild] private ListBox CountryListBox;
		public string selected_country = "";

		[GtkChild] private Revealer StateRevealer;
		[GtkChild] private Button SelectStateButton;
		[GtkChild] private Button ClearStateButton;
		[GtkChild] private ListBox StateListBox;
		public string selected_state = "";

		[GtkChild] private Revealer LanguageRevealer;
		[GtkChild] private Button SelectLanguageButton;
		[GtkChild] private Button ClearLanguageButton;
		[GtkChild] private ListBox LanguageListBox;
		public string selected_language = "";

		[GtkChild] private SpinButton BitrateSpinButton;
		public int min_bitrate = 0;

		public signal void information_changed();

		public FilterBox(){
			connect_signals();
		}

		private void connect_signals(){
			if(!App.ciprovider.is_ready){
				App.ciprovider.loaded.connect(fill_lists);
			}else{
				fill_lists();
			}

			CountryListBox.row_activated.connect((t,a) => {
				string selected_item = a.get_data("ITEM");
				SelectCountryButton.set_label(selected_item);

				selected_country = selected_item;

				CountryRevealer.set_reveal_child(false);
				ClearCountryButton.set_visible(true);
				SelectStateButton.set_sensitive(false);

				information_changed();
			});

			StateListBox.row_activated.connect((t,a) => {
				string selected_item = a.get_data("ITEM");
				SelectStateButton.set_label(selected_item);

				selected_state = selected_item;

				StateRevealer.set_reveal_child(false);
				SelectCountryButton.set_sensitive(false);
				ClearStateButton.set_visible(true);

				information_changed();
			});

			LanguageListBox.row_activated.connect((t,a) => {
				string selected_item = a.get_data("ITEM");
				SelectLanguageButton.set_label(selected_item);

				selected_language = selected_item;

				LanguageRevealer.set_reveal_child(false);
				ClearLanguageButton.set_visible(true);

				information_changed();
			});
		}

		private void fill_lists(){
			LanguageListBox.bind_model(CategoryItemProvider.languages_model, (i) => {
				GenericItem item = (GenericItem)i;
				return get_row(item.text);
			});

			CountryListBox.bind_model(CategoryItemProvider.countries_model, (i) => {
				GenericItem item = (GenericItem)i;
				return get_row(item.text);
			});

			StateListBox.bind_model(CategoryItemProvider.states_model, (i) => {
				GenericItem item = (GenericItem)i;
				return get_row(item.text);
			});
		}

		private void unreveal_all(){
			CountryRevealer.set_reveal_child(false);
			StateRevealer.set_reveal_child(false);
			LanguageRevealer.set_reveal_child(false);
		}

		private void clear_selected_country(){
			selected_country = "";
			SelectCountryButton.set_label("Select Country ...");
			ClearCountryButton.set_visible(false);
			SelectStateButton.set_sensitive(true);

			information_changed();
		}

		[GtkCallback]
		private void SelectCountryButton_clicked(){
			unreveal_all();
			CountryRevealer.set_reveal_child(!CountryRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearCountryButton_clicked(){
			clear_selected_country();
		}

		private void clear_selected_state(){
			selected_state = "";
			SelectStateButton.set_label("Select State ...");
			ClearStateButton.set_visible(false);
			SelectCountryButton.set_sensitive(true);

			information_changed();
		}

		[GtkCallback]
		private void SelectStateButton_clicked(){
			unreveal_all();
			StateRevealer.set_reveal_child(!StateRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearStateButton_clicked(){
			clear_selected_state();
		}

		private void clear_selected_language(){
			selected_language = "";
			SelectLanguageButton.set_label("Select Language ...");
			ClearLanguageButton.set_visible(false);

			information_changed();
		}

		[GtkCallback]
		private void SelectLanguageButton_clicked(){
			unreveal_all();
			LanguageRevealer.set_reveal_child(!LanguageRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearLanguageButton_clicked(){
			clear_selected_language();
		}


		[GtkCallback]
		private void BitrateSpinButton_value_changed(){
			min_bitrate = (int)BitrateSpinButton.get_value();
			information_changed();
		}

		[GtkCallback]
		private void SortRadioButton_toggled(ToggleButton button){
			if(button.active){
				if(button == VotesRButton) sort_by = "votes";
				if(button == NameRButton) sort_by = "name";
				if(button == LanguageRButton) sort_by = "language";
				if(button == CountryRButton) sort_by = "country";
				if(button == StateRButton) sort_by = "state";
				if(button == BitrateRButton) sort_by = "bitrate";
				if(button == ClicksRButton) sort_by = "clickcount";
				if(button == ClickTimestampRButton) sort_by = "clicktimestamp";

				information_changed();
			}
		}

		[GtkCallback]
		private void SortDescendingButton_toggled(){
			if(SortDescendingButton.active){
				SortAscendingButton.set_active(false);
				sort_descending = true;
			}
			information_changed();
		}

		[GtkCallback]
		private void SortAscendingButton_toggled(){
			if(SortAscendingButton.active){
				SortDescendingButton.set_active(false);
				sort_descending = false;
			}
			information_changed();
		}

		[GtkCallback]
		private void SearchEntry_search_changed () {
			if(SearchEntry.get_text() != "" && SearchEntry.get_text().length >= 3){
				search_term = SearchEntry.get_text();
			}
			information_changed();
		}

		[GtkCallback]
		private void ResetButton_clicked () {
			reset_filters();
		}

		private void reset_filters(){
			ClearCountryButton_clicked();
			ClearLanguageButton_clicked();
			ClearStateButton_clicked();

			VotesRButton.set_active(true);
			SortAscendingButton.set_active(true);

			BitrateSpinButton.set_value(0.0);
			min_bitrate = 0;
		}

		public void show_most_voted (){
			reset_filters();
			SortDescendingButton.set_active(true);
		}

		public void show_most_clicked (){
			reset_filters();
			SortDescendingButton.set_active(true);
			ClicksRButton.set_active(true);
		}

		public void show_recently_clicked (){
			reset_filters();
			SortDescendingButton.set_active(true);
			ClickTimestampRButton.set_active(true);
		}

		private ListBoxRow get_row(string text){
			ListBoxRow row = new ListBoxRow();

			Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			box.vexpand = true;

			Gtk.Box rowbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			rowbox.add(box);
			row.add(rowbox);

			Label label = new Label (text);
			label.margin = 5;
			box.add(label);

			Separator sep = new Separator(Gtk.Orientation.HORIZONTAL);
			sep.set_halign(Align.FILL);
			sep.set_valign(Align.END);
			rowbox.pack_end(sep);

			row.height_request = 40;
			row.set_data("ITEM", text);
			row.show_all();

			return row;
		}
	}
}
