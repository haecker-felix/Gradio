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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/headerbar.ui")]
	public class Headerbar : Gtk.Stack{

		public signal void selection_canceled();
		public signal void selection_started();
		public signal void search_toggled();

		public signal void select_all();
		public signal void select_none();

		//
		// Default
		//
		[GtkChild] public Gtk.Button AddButton;
		[GtkChild] public Gtk.ToggleButton LibraryToggleButton;
		[GtkChild] public Gtk.ToggleButton CollectionsToggleButton;
		[GtkChild] private Gtk.Stack TitleStack;
		[GtkChild] private Gtk.Label PageTitle;
		[GtkChild] public Gtk.Button SelectButton;
		[GtkChild] public Gtk.Button BackButton;
		[GtkChild] public Gtk.ToggleButton SearchButton;
		[GtkChild] public Gtk.Button ViewButton;

		//
		// Selection
		//
		[GtkChild] private Gtk.MenuButton SelectionMenuButton;
		[GtkChild] private Gtk.Label SelectionMenuButtonLabel;

		//
		// View Popover
		//
		[GtkChild] private Gtk.Button ZoomInButton;
		[GtkChild] private Gtk.Button ZoomOutButton;

		public int actual_zoom = 100;
		private const int min_zoom = 50;
		private const int max_zoom = 250;
		private const int zoom_steps = 25;


		public Headerbar(){
			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/ui/selection-menu.ui");
			var selection_menu = builder.get_object ("selection-menu") as GLib.MenuModel;

			SelectionMenuButtonLabel.set_text("Click on items to select them");
			SelectionMenuButton.set_menu_model(selection_menu);

			actual_zoom = Gradio.Settings.icon_zoom;
			if(actual_zoom == max_zoom)
				ZoomInButton.set_sensitive(false);
			if(actual_zoom == min_zoom)
				ZoomOutButton.set_sensitive(false);
		}

		public void set_selected_items(int i){
			if(i == 0){
				SelectionMenuButtonLabel.set_text("Click on items to select them");
			}else{
				SelectionMenuButtonLabel.set_text(i.to_string() + " selected");
			}
		}

		public void show_title(string t){
			TitleStack.set_visible_child_name("label");
			PageTitle.set_text(t);
		}

		public void show_default_buttons(){
			TitleStack.set_visible_child_name("stackswitcher");
			SelectButton.set_visible(true);
			SearchButton.set_visible(true);
			ViewButton.set_visible(true);
			AddButton.set_visible(false);
		}

		public void show_selection_bar(){
			this.set_visible_child_name("selection");
		}

		public void show_default_bar(){
			this.set_visible_child_name("default");
		}

		[GtkCallback]
		private void CancelSelectionButton_clicked(Gtk.Button button){
			selection_canceled();
			show_default_bar();
		}

		[GtkCallback]
		private void SelectButton_clicked(Gtk.Button button){
			selection_started();
			show_selection_bar();
		}

		[GtkCallback]
		private void SearchButton_toggled (){
			search_toggled();
		}

		[GtkCallback]
		private void ZoomInButton_clicked(Gtk.Button button){
			ZoomOutButton.set_sensitive(true);
			if((actual_zoom + zoom_steps) <= max_zoom){
				actual_zoom = actual_zoom  + zoom_steps;
				Gradio.Settings.icon_zoom = actual_zoom;
				App.window.update_icons();

				if(actual_zoom == max_zoom)
					ZoomInButton.set_sensitive(false);
			}
		}

		[GtkCallback]
		private void ZoomOutButton_clicked(Gtk.Button button){
			ZoomInButton.set_sensitive(true);
			if((actual_zoom - zoom_steps) >= min_zoom){
				actual_zoom = actual_zoom  - zoom_steps;
				Gradio.Settings.icon_zoom = actual_zoom;
				App.window.update_icons();

				if(actual_zoom == min_zoom)
					ZoomOutButton.set_sensitive(false);
			}
		}
	}
}
