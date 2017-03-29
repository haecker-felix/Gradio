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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/search-popover.ui")]
	public class SearchPopover : Gtk.Popover{

		[GtkChild] private Revealer CountryRevealer;
		[GtkChild] private Button SelectCountryButton;
		[GtkChild] private Button ClearCountryButton;
		[GtkChild] private ListBox CountryListBox;

		public string selected_country = "";

		public SearchPopover(){
			connect_signals();
		}

		private void connect_signals(){
			if(!App.ciprovider.is_ready){
				App.ciprovider.loaded.connect(fill_lists);
			}else{
				fill_lists();
			}

			CountryListBox.row_activated.connect((t,a) => {
				ListBoxRow row = a;
				Label l = (Label) a.get_child();

				selected_country = l.get_text();
				SelectCountryButton.set_label(selected_country);

				CountryRevealer.set_reveal_child(false);
				ClearCountryButton.set_visible(true);
			});
		}

		private void fill_lists(){
			App.ciprovider.countries_list.foreach ((s) => {
				Label l = new Label (s);
				l.set_halign(Align.START);
				l.set_visible(true);
				CountryListBox.add(l);
			});
		}

		[GtkCallback]
		private void SelectCountryButton_clicked(Button button){
			CountryRevealer.set_reveal_child(!CountryRevealer.get_child_revealed());
		}

		[GtkCallback]
		private void ClearCountryButton_clicked(Button button){
			selected_country = "";
			SelectCountryButton.set_label("Select Country ...");
			ClearCountryButton.set_visible(false);
		}

	}
}
