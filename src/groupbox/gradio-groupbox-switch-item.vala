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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/item/switch-item.ui")]
	public class SwitchItem : Gtk.ListBoxRow, GroupBoxItem{

		[GtkChild] private Label Title;
		[GtkChild] private Label Subtitle;
		[GtkChild] private Switch switchbutton;

		public signal void toggled ();

		public SwitchItem(string title, string subtitle = ""){
			Title.set_text(title);
			Subtitle.set_text(subtitle);

			switchbutton.notify["active"].connect(() => {
				toggled();
			});
		}

		public new bool get_state(){
			return switchbutton.get_state();
		}

		public new void set_state(bool b){
			switchbutton.set_state(b);
		}

		private void clicked(){
			switchbutton.set_state(!switchbutton.get_state());
			toggled();
		}
	}
}

