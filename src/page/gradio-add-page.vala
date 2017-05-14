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

			ButtonItem discover_button = new ButtonItem("Discover new stations", "Show stations for different categories.");
			discover_button.btn_clicked.connect(() => {App.window.show_discover();});
			add_group.add_listbox_row(discover_button);

			ButtonItem search_button = new ButtonItem("Search for stations", "Search for specific stations.");
			search_button.btn_clicked.connect(() => {App.window.show_search();});
			add_group.add_listbox_row(search_button);

			//ButtonItem create_button = new ButtonItem("Create a new station", "Create a completely new station.");
			//add_group.add_listbox_row(create_button);

			AddBox.pack_end(add_group);
		}
	}

}
