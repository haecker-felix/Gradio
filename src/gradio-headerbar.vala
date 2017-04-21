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

		//
		// Default
		//
		[GtkChild] public Gtk.ToggleButton DiscoverToggleButton;
		[GtkChild] public Gtk.ToggleButton LibraryToggleButton;
		[GtkChild] private Gtk.Stack TitleStack;
		[GtkChild] private Gtk.Label PageTitle;
		[GtkChild] public Gtk.Button SelectButton;
		[GtkChild] private Gtk.VolumeButton VolumeButton;
		[GtkChild] public Gtk.Button BackButton;
		[GtkChild] public Gtk.ToggleButton SearchButton;
		[GtkChild] private Gtk.Button CancelSelectionButton;

		//
		// Selection
		//
		[GtkChild] private Gtk.MenuButton SelectionMenuButton;
		[GtkChild] private Gtk.Label SelectionMenuButtonLabel;

		public Headerbar(){
			VolumeButton.set_relief(Gtk.ReliefStyle.NORMAL);
			VolumeButton.set_value(Settings.volume_position);
		}

		private void connect_signals(){
			CancelSelectionButton.clicked.connect(() => {

			});
		}

		public void show_title(string t){
			TitleStack.set_visible_child_name("label");
			PageTitle.set_text(t);
		}

		public void show_default_buttons(){
			TitleStack.set_visible_child_name("stackswitcher");
			SelectButton.set_visible(true);
			SearchButton.set_visible(true);
		}

		public void show_selection_bar(){
			this.set_visible_child_name("selection");
			selection_started();
		}

		public void show_default_bar(){
			this.set_visible_child_name("default");
			selection_canceled();
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
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			Settings.volume_position = value;
		}

		[GtkCallback]
		private void SearchButton_toggled (){
			search_toggled();
		}

	}
}
