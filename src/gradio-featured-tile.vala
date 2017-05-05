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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/featured-tile.ui")]
	public class FeaturedTile : Gtk.Button{

		[GtkChild] private Label StationTitle;
		[GtkChild] private Label StationDescription;
		[GtkChild] private Image StationLogo;

		public FeaturedTile(RadioStation station){
			StationTitle.set_text(station.title);

			// Logo
			var image_cache = new ImageCache();
                	image_cache.get_image.begin(station.icon_address, (obj, res) => {
		            	Gdk.Pixbuf pixbuf = image_cache.get_image.end(res);
		            	if (pixbuf != null) {
		                	StationLogo.clear();
		                	pixbuf = pixbuf.scale_simple(192, 192, Gdk.InterpType.BILINEAR);
		                	StationLogo.set_from_pixbuf(pixbuf);
		            	}
			});

			// Description
			station.get_description.begin((obj,res) => {
				string desc = station.get_description.end(res);
				StationDescription.set_text(desc);
				StationDescription.set_visible(true);
			});

			this.clicked.connect(() => {
				Gradio.App.window.show_station_details(station);
			});
		}
	}
}
