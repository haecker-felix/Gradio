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

		[GtkChild] private Frame MostVotesFrame;
		[GtkChild] private Frame RecentlyClickedFrame;
		[GtkChild] private Frame MostClicksFrame;

		[GtkChild] private SearchEntry StationSearchEntry;

		public AddPage(){
			GroupBox add_group = new GroupBox(_("Create a new radio station"));

			HashTable<string, string> filter_table = new HashTable<string, string> (str_hash, str_equal);

			MainBox most_votes_mainbox = new MainBox();
			MainBox recently_clicked_mainbox = new MainBox();
			MainBox most_clicks_mainbox = new MainBox();

			StationModel most_votes_model = new StationModel();
			StationModel recently_clicked_model = new StationModel();
			StationModel most_clicks_model = new StationModel();

			StationProvider most_votes_provider = new StationProvider(ref most_votes_model);
			StationProvider recently_clicked_provider = new StationProvider(ref recently_clicked_model);
			StationProvider most_clicks_provider = new StationProvider(ref most_clicks_model);

			most_votes_provider.get_stations.begin(RadioBrowser.most_votes(10), filter_table);
			recently_clicked_provider.get_stations.begin(RadioBrowser.recently_clicked(10), filter_table);
			most_clicks_provider.get_stations.begin(RadioBrowser.most_clicks(10), filter_table);

			most_votes_mainbox.set_model(most_votes_model);
			recently_clicked_mainbox.set_model(recently_clicked_model);
			most_clicks_mainbox.set_model(most_clicks_model);

			most_votes_mainbox.set_show_secondary_text(false);
			recently_clicked_mainbox.set_show_secondary_text(false);
			most_clicks_mainbox.set_show_secondary_text(false);

			MostVotesFrame.add(most_votes_mainbox);
			RecentlyClickedFrame.add(recently_clicked_mainbox);
			MostClicksFrame.add(most_clicks_mainbox);

			most_votes_mainbox.selection_changed.connect(() => {selection_changed();});
			most_votes_mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});

			ButtonItem create_public_button = new ButtonItem(_("New public radio station"), _("Create a new radio station, which is visible for all users."));
			create_public_button.btn_clicked.connect(() => {show_create_station_dialog();});
			add_group.add_listbox_row(create_public_button);

			//ButtonItem create_private_button = new ButtonItem(_("New private radio station", "Create a new radio station, which is only visible in your library."));
			//create_private_button.btn_clicked.connect(() => {App.window.show_create_station_dialog();});
			//add_group.add_listbox_row(create_private_button);

			AddBox.pack_end(add_group);

		}

		[GtkCallback]
		private void StationSearchEntry_search_changed(){
			App.window.set_mode(WindowMode.SEARCH);
			App.window.search_page.set_search(StationSearchEntry.get_text());
		}

		[GtkCallback]
		private void MostVotesButton_clicked(){
			App.window.set_mode(WindowMode.SEARCH);
			App.window.search_page.show_most_voted();
		}

		[GtkCallback]
		private void RecentlyClickedButton_clicked(){
			App.window.set_mode(WindowMode.SEARCH);
			App.window.search_page.show_recently_clicked();
		}

		[GtkCallback]
		private void MostClicksButton_clicked(){
			App.window.set_mode(WindowMode.SEARCH);
			App.window.search_page.show_most_clicks();
		}

		private void show_create_station_dialog(){
			StationEditorDialog editor_dialog = new StationEditorDialog.create();
			editor_dialog.set_transient_for(App.window);
			editor_dialog.set_modal(true);
			editor_dialog.set_visible(true);
		}
	}

}
