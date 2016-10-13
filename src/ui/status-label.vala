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
using WebKit;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/status-label.ui")]
	public class StatusLabel : Gtk.Box{

		[GtkChild]
		private Stack StatusStack;
		[GtkChild]
		private Stack PopoverStack;
		[GtkChild]
		private Popover InfoPopover;

		[GtkChild]
		private Label NominalBitrateLabel;
		[GtkChild]
		private Label MinimumBitrateLabel;
		[GtkChild]
		private Label MaximumBitrateLabel;
		[GtkChild]
		private Label BitrateLabel;
		[GtkChild]
		private Label CodecLabel;
		[GtkChild]
		private Label ChannelModeLabel;

		public StatusLabel(){
			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
			App.player.connection_established.connect(() => show_connected());
			App.player.connection_error.connect(() => show_error());
			App.player.no_connection.connect(() => show_no_connection());
			App.player.tag_changed.connect (() => set_information());
		}

		[GtkCallback]
		private bool status_clicked (Gdk.EventButton button){
			message("clicked");
			InfoPopover.set_relative_to(this);
			InfoPopover.show_all();

			return false;
		}

		private void set_information(){
			NominalBitrateLabel.set_text(App.player.tag_nominal_bitrate.to_string() + " kBit/s");
			MinimumBitrateLabel.set_text(App.player.tag_minimum_bitrate.to_string() + " kBit/s");
			MaximumBitrateLabel.set_text(App.player.tag_maximum_bitrate.to_string() + " kBit/s");
			BitrateLabel.set_text(App.player.tag_bitrate.to_string()  + " kBit/s");
			CodecLabel.set_text(App.player.tag_audio_codec);
			ChannelModeLabel.set_text(App.player.tag_channel_mode);
		}

		private void show_no_connection(){
			StatusStack.set_visible_child_name("no-connection");
		}

		private void show_connected(){
			StatusStack.set_visible_child_name("connected");
		}

		private void show_error(){
			StatusStack.set_visible_child_name("error");
		}

	}
}
