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

		public StatusLabel(){
			this.show_all();
		}

		public void show_no_connection(){
			StatusStack.set_visible_child_name("no-connection");
		}

		public void show_connected(){
			StatusStack.set_visible_child_name("connected");
		}

		public void show_error(){
			StatusStack.set_visible_child_name("error");
		}

	}
}
