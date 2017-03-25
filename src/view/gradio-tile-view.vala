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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/view/big-tile-view.ui")]
	public class TileView : Gtk.FlowBox, View{

		public StationModel model;

		public TileView(ref StationModel m){
			model = m;

			connect_signals();
		}

		private void connect_signals(){
			this.bind_model (this.model, (obj) => {
     				assert (obj is RadioStation);

				weak RadioStation station = (RadioStation)obj;
				BigTile item = new BigTile(station);

      				return item;
			});

			this.child_activated.connect((t,a) => {
				BigTile btile = (BigTile)a;
				Gradio.App.window.show_station_details(btile.station);
			});

		}
	}
}
