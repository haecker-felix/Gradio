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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/headerbar.ui")]
	public class Headerbar : Gtk.Stack{

		public signal void selection_canceled();
		public signal void selection_started();

		public signal void select_all();
		public signal void select_none();

		//
		// Default
		//
		[GtkChild] public Gtk.Button AddButton;
		[GtkChild] public Gtk.ToggleButton LibraryToggleButton;
		[GtkChild] private Gtk.Stack TitleStack;
		[GtkChild] private Gtk.Label PageTitle;
		[GtkChild] public Gtk.Button SelectButton;
		[GtkChild] public Gtk.Button BackButton;
		[GtkChild] public Gtk.ToggleButton SearchToggleButton;
		[GtkChild] public Gtk.Box MenuBox;

		//
		// Selection
		//
		[GtkChild] private Gtk.MenuButton SelectionMenuButton;
		[GtkChild] private Gtk.Label SelectionMenuButtonLabel;

		public Headerbar(){
			var builder = new Gtk.Builder.from_resource ("/de/haecker-felix/gradio/ui/selection-menu.ui");
			var selection_menu = builder.get_object ("selection-menu") as GLib.MenuModel;

			Gradio.MenuButton mbutton = new Gradio.MenuButton();
			MenuBox.add(mbutton);

			SelectionMenuButtonLabel.set_text("Click on items to select them");
			SelectionMenuButton.set_menu_model(selection_menu);
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
			SearchToggleButton.set_visible(true);
			MenuBox.set_visible(true);
			AddButton.set_visible(false);
		}

		public void show_selection_bar(bool b){
			if(b)
				this.set_visible_child_name("selection");
			else
				this.set_visible_child_name("default");
		}

		[GtkCallback]
		private void CancelSelectionButton_clicked(Gtk.Button button){
			selection_canceled();
			show_selection_bar(false);
		}

		[GtkCallback]
		private void SelectButton_clicked(Gtk.Button button){
			selection_started();
			show_selection_bar(true);
		}
	}
}
