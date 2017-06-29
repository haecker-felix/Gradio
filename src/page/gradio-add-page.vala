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
			GroupBox add_group = new GroupBox("Create a new radio station");
			GroupBox discover_group = new GroupBox("Discover radio stations");
			GroupBox other_group = new GroupBox("");

			ButtonItem most_votes_button = new ButtonItem("Show famous radio stations", "Show radio stations which have the most votes.");
			most_votes_button.btn_clicked.connect(() => {App.window.set_mode(WindowMode.SEARCH); App.window.search_page.show_most_voted();});
			discover_group.add_listbox_row(most_votes_button);

			ButtonItem most_clicked_button = new ButtonItem("Show popular radio stations", "Show radio stations which have the most clicks.");
			most_clicked_button.btn_clicked.connect(() => {App.window.set_mode(WindowMode.SEARCH); App.window.search_page.show_most_clicked();});
			discover_group.add_listbox_row(most_clicked_button);

			ButtonItem recently_clicked_button = new ButtonItem("Show recent radio stations", "Show radio stations which have recently been clicked.");
			recently_clicked_button.btn_clicked.connect(() => {App.window.set_mode(WindowMode.SEARCH); App.window.search_page.show_recently_clicked();});
			discover_group.add_listbox_row(recently_clicked_button);

			ButtonItem search_button = new ButtonItem("Search for radio stations", "Search for specific radio stations.");
			search_button.btn_clicked.connect(() => {App.window.set_mode(WindowMode.SEARCH);});
			other_group.add_listbox_row(search_button);

			ButtonItem create_public_button = new ButtonItem("New public radio station", "Create a new radio station, which is visible for all users.");
			create_public_button.btn_clicked.connect(() => {show_create_station_dialog();});
			add_group.add_listbox_row(create_public_button);

			//ButtonItem create_private_button = new ButtonItem("New private radio station", "Create a new radio station, which is only visible in your library.");
			//create_private_button.btn_clicked.connect(() => {App.window.show_create_station_dialog();});
			//add_group.add_listbox_row(create_private_button);

			AddBox.pack_end(add_group);
			AddBox.pack_end(discover_group);
			AddBox.pack_end(other_group);

		}

		private void show_create_station_dialog(){
			StationEditorDialog editor_dialog = new StationEditorDialog.create();
			editor_dialog.set_transient_for(App.window);
			editor_dialog.set_modal(true);
			editor_dialog.set_visible(true);
		}
	}

}
