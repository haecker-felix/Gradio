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

	public class MainBox : Gd.MainBox{

		public MainBox(){
			Object(box_type: Gd.MainBoxType.ICON);

			this.set_show_primary_text(true);
			this.set_show_secondary_text(true);
			this.show_all();

			//this.get_style_context().add_class("grid-item");

			connect_signals();
		}

		private void connect_signals(){
			this.selection_mode_request.connect(() => {
				this.set_selection_mode(true);
			});

			this.item_activated.connect((t,a) => {
				if(Util.is_collection_item(int.parse(a.id))){
					message("clicked a collection item");
				}else{
					if(App.player.current_station.id == (string)a.id)
						Gradio.App.window.show_station_details((RadioStation)a);
					else
						App.player.set_radio_station((RadioStation)a);
				}
			});
		}
	}
}
