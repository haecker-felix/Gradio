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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/item/big-tile-item.ui")]
	public class BigTile : Gtk.FlowBoxChild, Item{

		[GtkChild]
		private Label StationTitleLabel;
		[GtkChild]
		private Label StationLikesLabel;
		[GtkChild]
		private Image StationLogoImage;


		public RadioStation station;

		public BigTile(RadioStation s){
			station = s;

			// Set information
			StationTitleLabel.set_text(station.Title);
			StationLikesLabel.set_text(station.Votes.to_string());
			set_logo();
		}

		private void set_logo(){
			//TODO: insert logo loader here
		}

	}
}

