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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/discover-page.ui")]
	public class DiscoverPage : Gtk.Box, Page{

		[GtkChild] private Box FeaturedBox;
		[GtkChild] private Box ClickedStationsBox;
		[GtkChild] private Box ChangedStationsBox;

		[GtkChild] private FlowBox LanguagesFlowBox;

		public DiscoverPage(){
			setup_view();
			connect_signals();
		}

		private void connect_signals(){
			if(!App.ciprovider.is_ready){
				App.ciprovider.loaded.connect(fill_lists);
			}else{
				fill_lists();
			}
		}

		private void setup_view(){
			// featured
			StationModel featured_stations = new StationModel();
			StationProvider popular_stations_provider = new StationProvider(ref featured_stations);
			popular_stations_provider.set_address(RadioBrowser.most_votes(5));
			FeaturedTileStack featured_tile_stack = new FeaturedTileStack(ref featured_stations);
			FeaturedBox.pack_start(featured_tile_stack);

			// recently changed
			StationModel changed_stations = new StationModel();
			StationProvider changed_stations_provider = new StationProvider(ref changed_stations);
			changed_stations_provider.set_address(RadioBrowser.recently_changed(12));
			MainBox changed_stations_box = new MainBox();
			changed_stations_box.set_model(changed_stations);
			ChangedStationsBox.pack_start(changed_stations_box);

			// recently clicked
			StationModel clicked_stations = new StationModel();
			StationProvider clicked_stations_provider = new StationProvider(ref clicked_stations);
			clicked_stations_provider.set_address(RadioBrowser.recently_clicked(12));
			MainBox clicked_stations_box = new MainBox();
			clicked_stations_box.set_model(clicked_stations);
			ClickedStationsBox.pack_end(clicked_stations_box);
		}

		private void fill_lists(){
			//CategoryItemProvider.languages_list.foreach ((s) => {
			//	Label l = new Label (s);
			//	l.height_request = 30;
			//	l.set_halign(Align.START);
			//	l.set_visible(true);
			//	LanguagesFlowBox.add(l);
			//});
		}

		[GtkCallback]
		private void MorePopularStations_clicked(){
			App.window.show_stations_by_adress(RadioBrowser.most_votes(100), "Popular Stations");
		}

		[GtkCallback]
		private void MoreRecentlyChanged_clicked(){
			App.window.show_stations_by_adress(RadioBrowser.recently_changed(100), "Recently Changed Stations");
		}

		[GtkCallback]
		private void MoreRecentlyClicked_clicked(){
			App.window.show_stations_by_adress(RadioBrowser.recently_clicked(100), "Recently Clicked Stations");
		}
	}
}
