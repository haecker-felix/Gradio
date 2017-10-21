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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/search-page.ui")]
	public class SearchPage : Gtk.Box, Page{
		[GtkChild] private Box ResultsBox;
		[GtkChild] private Box SearchBox;
		[GtkChild] private Stack SearchStack;
		private SearchBar searchbar;

		private MainBox mainbox;
		private StationModel station_model;
		private StationProvider station_provider;

		public SearchPage(){
			station_model =  new StationModel();
			station_provider = new StationProvider(ref station_model);

			searchbar = new Gradio.SearchBar(ref station_provider);
			SearchBox.add(searchbar);

			mainbox = new MainBox();
			mainbox.set_model(station_model);
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});
			ResultsBox.add(mainbox);

			station_provider.ready.connect(() => {
				if(station_model.get_n_items() == 0)
					SearchStack.set_visible_child_name("no-results");
				else
					SearchStack.set_visible_child_name("results");
			});
			station_provider.working.connect(() => {SearchStack.set_visible_child_name("loading");});
			searchbar.timeout_reset.connect(() => {SearchStack.set_visible_child_name("loading");});
		}

		public void set_search(string term){
			searchbar.set_search(term);
		}

		public void show_recently_clicked(){
			searchbar.reset_filters();
			App.settings.sort_ascending = false;
			App.settings.station_sorting = Compare.DATE;
		}

		public void show_most_voted(){
			searchbar.reset_filters();
			App.settings.sort_ascending = false;
			App.settings.station_sorting = Compare.VOTES;
		}

		public void show_most_clicks(){
			searchbar.reset_filters();
			App.settings.sort_ascending = false;
			App.settings.station_sorting = Compare.CLICKS;
		}

		public void set_selection_mode(bool b){
			mainbox.set_selection_mode(b);
		}

		public void select_all(){
			mainbox.select_all();
		}

		public void select_none(){
			mainbox.unselect_all();
		}

		public StationModel get_selection(){
			List<Gd.MainBoxItem> selection = mainbox.get_selection();
			StationModel model = new StationModel();

			foreach(Gd.MainBoxItem item in selection){
				model.add_item(item);
			}
			return model;
		}
	}
}


