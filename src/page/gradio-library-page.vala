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
using Gd;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/library-page.ui")]
	public class LibraryPage : Gtk.Box, Page{

		private MainBox mainbox;
		private StationModel station_model;

		[GtkChild]
		private Box StationBox;


		public LibraryPage(){
			mainbox = new MainBox(MainBoxType.ICON);
			mainbox.expand = true;
			mainbox.set_show_primary_text(true);
			mainbox.set_show_secondary_text(true);

			station_model = Library.library_model;
			mainbox.set_model(station_model);
			mainbox.show_all();

			connect_signals();
			StationBox.add(mainbox);
		}

		private void connect_signals(){
			//station_model.empty.connect(() => {
			//	station_view.show_empty_library();
			//});
		}
	}
}
