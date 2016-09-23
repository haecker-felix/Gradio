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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/release-notes.ui")]
	public class ReleaseNotes : Gtk.Window{

		[GtkChild]
		private Box Placeholder;

		private WebView notes;

		public ReleaseNotes(){
			this.set_keep_above(true);

			notes = new WebView();
			Placeholder.add(notes);

			notes.show();
			notes.set_vexpand(true);

			notes.load_uri("https://raw.githubusercontent.com/haecker-felix/gradio/master/README.md");
		}

		[GtkCallback]
		private void CloseButton_clicked (Button button){
			this.close();
		}

		[GtkCallback]
		private void MoreInformationButton_clicked (Button button){
			Util.open_website("https://raw.githubusercontent.com/haecker-felix/gradio/master/README.md");
		}
	}
}
