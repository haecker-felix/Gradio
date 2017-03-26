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

		[GtkChild]
		private Box Home;

		public DiscoverPage(){
			setup_view();
		}

		private void setup_view(){
			StationModel popular_station_model = new StationModel();
			StationProvider popular_station_provider = new StationProvider(ref popular_station_model, 12);
			popular_station_provider.set_address(RadioBrowser.radio_stations_most_votes);

			GroupBox popular_stations_group = new GroupBox("Popular Stations");
			TileView popular_btile_view = new TileView(ref popular_station_model);
			popular_stations_group.add_widget(popular_btile_view);

			Home.pack_start(popular_stations_group);


			StationModel recently_clicked_station_model = new StationModel();
			StationProvider recently_clicked_station_provider = new StationProvider(ref recently_clicked_station_model, 12);
			recently_clicked_station_provider.set_address(RadioBrowser.radio_stations_recently_clicked);

			GroupBox recently_clicked_stations_group = new GroupBox("Recently Clicked");
			TileView recently_clicked_btile_view = new TileView(ref recently_clicked_station_model);
			recently_clicked_stations_group.add_widget(recently_clicked_btile_view);

			Home.pack_start(recently_clicked_stations_group);
		}
	}
}
