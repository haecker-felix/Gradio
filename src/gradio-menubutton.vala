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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/menubutton.ui")]
	public class MenuButton : Gtk.MenuButton{

		[GtkChild] public Gtk.Button ZoomInButton;
		[GtkChild] public Gtk.Button ZoomOutButton;

		[GtkChild] public Gtk.Box AppBox;

		public int actual_zoom = 100;
		private const int min_zoom = 50;
		private const int max_zoom = 175;
		private const int zoom_steps = 25;

		public MenuButton(){
			// if(App.settings.sort_ascending){
			// 	SortAscendingButton.set_active(true);
			// 	SortDescendingButton.set_active(false);
			// }else{
			// 	SortAscendingButton.set_active(false);
			// 	SortDescendingButton.set_active(true);
			// }

			actual_zoom = Gradio.App.settings.icon_zoom;
			if(actual_zoom == max_zoom) ZoomInButton.set_sensitive(false);
			if(actual_zoom == min_zoom) ZoomOutButton.set_sensitive(false);

			// Show app actions on non GNOME desktops in menu popover
			if(!(GLib.Environment.get_variable("DESKTOP_SESSION")).contains("gnome")) {
				AppBox.set_visible(true);
			}

		}

		[GtkCallback]
		private void ZoomInButton_clicked(Gtk.Button button){
			ZoomOutButton.set_sensitive(true);
			if((actual_zoom + zoom_steps) <= max_zoom){
				actual_zoom = actual_zoom  + zoom_steps;
				Gradio.App.settings.icon_zoom = actual_zoom;

				if(actual_zoom == max_zoom)
					ZoomInButton.set_sensitive(false);
			}
		}

		[GtkCallback]
		private void ZoomOutButton_clicked(Gtk.Button button){
			ZoomInButton.set_sensitive(true);
			if((actual_zoom - zoom_steps) >= min_zoom){
				actual_zoom = actual_zoom  - zoom_steps;
				Gradio.App.settings.icon_zoom = actual_zoom;

				if(actual_zoom == min_zoom)
					ZoomOutButton.set_sensitive(false);
			}
		}
	}
}

