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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/status-icon.ui")]
	public class StatusIcon : Gtk.Box{

		[GtkChild] private Stack StatusStack;
		[GtkChild] private Stack PopoverStack;
		[GtkChild] private Popover InfoPopover;

		[GtkChild] private Label BitrateLabel;
		[GtkChild] private Label MessageLabel;

		public StatusIcon(){
			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
			App.player.notify["state"].connect(() => {
				switch(App.player.state){
					case Gst.State.PLAYING: StatusStack.set_visible_child_name("connected"); PopoverStack.set_visible_child_name("connected"); break;
					default: StatusStack.set_visible_child_name("no-connection"); PopoverStack.set_visible_child_name("no-connection"); break;
				}

			});

			App.player.notify["current-bitrate-tag"].connect(() => {BitrateLabel.set_label(App.player.current_bitrate_tag.to_string() + " kBit/s");});
			App.player.notify["status-message"].connect(() => {MessageLabel.set_label(App.player.status_message);});
		}

		[GtkCallback]
		private bool status_clicked (Gdk.EventButton button){
			InfoPopover.set_relative_to(this);
			InfoPopover.show_all();

			return false;
		}

	}
}
