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

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/selection-toolbar.ui")]
	public class SelectionToolbar : Gtk.Box{

		[GtkChild] private Gtk.Button AddToLibraryButton;
		[GtkChild] private Gtk.Button RemoveFromLibraryButton;

		public SelectionToolbar(){

		}

		public void set_library_mode(bool b){
			if(b){
				RemoveFromLibraryButton.set_visible(true);
				AddToLibraryButton.set_visible(false);
			}else{
				RemoveFromLibraryButton.set_visible(false);
				AddToLibraryButton.set_visible(true);
			}
		}

		[GtkCallback]
		public void ShareButton_clicked (Gtk.Button button) {

		}

		[GtkCallback]
		public void AddToCollectionButton_clicked (Gtk.Button button) {

		}

		[GtkCallback]
		public void RemoveFromLibraryButton_clicked (Gtk.Button button) {
			List<Gd.MainBoxItem> list = App.window.current_selection.copy();

			list.foreach ((station) => {
				App.library.remove_radio_station((RadioStation)station);
			});
		}

		[GtkCallback]
		public void AddToLibraryButton_clicked (Gtk.Button button) {
			List<Gd.MainBoxItem> list = App.window.current_selection.copy();

			list.foreach ((station) => {
				App.library.add_radio_station((RadioStation)station);
			});
		}

	}
}
