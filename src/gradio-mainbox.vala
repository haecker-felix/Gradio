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
			this.set_vexpand(true);
			this.show_all();

			Frame frame = (Frame)this.get_child();
			frame.set_shadow_type(ShadowType.NONE);

			connect_signals();
		}

		private void connect_signals(){
			this.selection_mode_request.connect(() => {
				this.set_selection_mode(true);
			});

			this.item_activated.connect((t,a) => {
				Gd.MainBoxItem item = (Gd.MainBoxItem)a;

				if(!Util.is_collection_item(int.parse(item.id))){
					if(App.player.station == (RadioStation)item)
						App.player.toggle_play_stop();
					else
						App.player.station = (RadioStation)item;
				}
			});
		}
	}
}
