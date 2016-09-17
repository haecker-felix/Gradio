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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		[GtkChild]
		private Box ContentBox;

		private StationsView library_view;

		public LibraryBox(){
			library_view = new StationsView("Library");
			library_view.set_stations_from_hash_table(App.library.lib);

			ContentBox.add(library_view);

			App.library.added_radio_station.connect(() => library_view.set_stations_from_hash_table(App.library.lib));
			App.library.removed_radio_station.connect(() => library_view.set_stations_from_hash_table(App.library.lib));

			library_view.clicked.connect((t) => Gradio.App.player.set_radio_station(t));

			ContentBox.show_all();
		}

		public void show_grid_view(){
			library_view.show_grid_view();
		}

		public void show_list_view(){
			library_view.show_list_view();
		}
	}
}
