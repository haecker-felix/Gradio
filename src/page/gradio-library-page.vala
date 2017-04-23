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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/library-page.ui")]
	public class LibraryPage : Gtk.Box, Page{

		[GtkChild] Viewport ScrollViewport;

		private MainBox mainbox;

		public LibraryPage(){
			mainbox = new MainBox();
			mainbox.set_model(Library.library_model);
			mainbox.selection_changed.connect(() => {selection_changed();});
			mainbox.selection_mode_request.connect(() => {selection_mode_enabled();});

			ScrollViewport.add(mainbox);
		}

		public void set_selection_mode(bool b){
			mainbox.set_selection_mode(b);
		}

		public void select_all(){
			mainbox.select_all();
		}

		public void select_none(){
			mainbox.unselect_all();
		}

		public GLib.List<Gd.MainBoxItem> get_selection(){
			return mainbox.get_selection();
		}
	}
}
