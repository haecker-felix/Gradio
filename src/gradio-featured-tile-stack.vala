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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/featured-tile-stack.ui")]
	public class FeaturedTileStack : Gtk.Box{

		[GtkChild] private Stack FeaturedStack;
		[GtkChild] private Stack MainStack;
		private StationModel model;


		public FeaturedTileStack(ref StationModel m){
			MainStack.set_visible_child_name("loading");

			model = m;

			model.items_changed.connect((position, removed, added) => {
				if(added == 1 && removed == 0){
					MainStack.set_visible_child_name("content");

					RadioStation station = (RadioStation)model.get_item(position);
					FeaturedTile tile = new FeaturedTile(station);

					FeaturedStack.add_titled(tile, station.id.to_string(), "•");
				}

			});
		}
	}
}
