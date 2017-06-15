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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/add-page.ui")]
	public class AddPage : Gtk.Box, Page{

		[GtkChild] private Box AddBox;

		public AddPage(){
			GroupBox add_group = new GroupBox("Options");

			ButtonItem most_votes_button = new ButtonItem("Show famous radio stations", "Show radio stations which have the most votes.");
			most_votes_button.btn_clicked.connect(() => {App.window.show_search(); App.window.search_page.show_most_voted();});
			add_group.add_listbox_row(most_votes_button);

			ButtonItem most_clicked_button = new ButtonItem("Show popular radio stations", "Show radio stations which have the most clicks.");
			most_clicked_button.btn_clicked.connect(() => {App.window.show_search(); App.window.search_page.show_most_clicked();});
			add_group.add_listbox_row(most_clicked_button);

			ButtonItem recently_clicked_button = new ButtonItem("Show recent radio stations", "Show radio stations which have recently been clicked.");
			recently_clicked_button.btn_clicked.connect(() => {App.window.show_search(); App.window.search_page.show_recently_clicked();});
			add_group.add_listbox_row(recently_clicked_button);

			ButtonItem search_button = new ButtonItem("Search for stations", "Search for specific stations.");
			search_button.btn_clicked.connect(() => {App.window.show_search();});
			add_group.add_listbox_row(search_button);

			//ButtonItem create_button = new ButtonItem("Create a new station", "Create a completely new station.");
			//add_group.add_listbox_row(create_button);

			AddBox.pack_end(add_group);
		}
	}

}
