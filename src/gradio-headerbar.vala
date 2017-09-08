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
		[GtkChild] public Gtk.ToggleButton SearchToggleButton;
		[GtkChild] public Gtk.Button ViewButton;

		//
		// Selection
		//
		[GtkChild] private Gtk.MenuButton SelectionMenuButton;
		[GtkChild] private Gtk.Label SelectionMenuButtonLabel;

		//
		// View Popover
		//
		[GtkChild] public Gtk.Button ZoomInButton;
		[GtkChild] public Gtk.Button ZoomOutButton;
		[GtkChild] public Gtk.RadioButton VotesRButton;
		[GtkChild] public Gtk.RadioButton NameRButton;
		[GtkChild] public Gtk.RadioButton LanguageRButton;
		[GtkChild] public Gtk.RadioButton CountryRButton;
		[GtkChild] public Gtk.RadioButton StateRButton;
		[GtkChild] public Gtk.RadioButton BitrateRButton;
		[GtkChild] public Gtk.RadioButton ClicksRButton;
		[GtkChild] public Gtk.RadioButton ClickTimestampRButton;
		[GtkChild] public Gtk.ToggleButton SortDescendingButton;
		[GtkChild] public Gtk.ToggleButton SortAscendingButton;

		[GtkChild] public Gtk.Box SortBox;

		public int actual_zoom = 100;
		private const int min_zoom = 50;
		private const int max_zoom = 175;
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

			switch(Settings.station_sorting){
				case Compare.VOTES: VotesRButton.set_active(true); break;
				case Compare.NAME: NameRButton.set_active(true); break;
				case Compare.LANGUAGE: LanguageRButton.set_active(true); break;
				case Compare.COUNTRY: CountryRButton.set_active(true); break;
				case Compare.BITRATE: BitrateRButton.set_active(true); break;
				case Compare.CLICKS: ClicksRButton.set_active(true); break;
				case Compare.STATE: StateRButton.set_active(true); break;
				case Compare.DATE: ClickTimestampRButton.set_active(true); break;
			}

			if(Settings.sort_ascending){
				SortAscendingButton.set_active(true);
				SortDescendingButton.set_active(false);
			}else{
				SortAscendingButton.set_active(false);
				SortDescendingButton.set_active(true);
			}
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
			ViewButton.set_visible(true);
			AddButton.set_visible(false);
			SortBox.set_visible(true);
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
		private void ZoomInButton_clicked(Gtk.Button button){
			ZoomOutButton.set_sensitive(true);
			if((actual_zoom + zoom_steps) <= max_zoom){
				actual_zoom = actual_zoom  + zoom_steps;
				Gradio.Settings.icon_zoom = actual_zoom;
				App.window.icon_zoom_changed();

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
				App.window.icon_zoom_changed();

				if(actual_zoom == min_zoom)
					ZoomOutButton.set_sensitive(false);
			}
		}

		[GtkCallback]
		private void SortRadioButton_toggled(Gtk.ToggleButton button){
			if(button.active){
				if(button == VotesRButton) Settings.station_sorting = Compare.VOTES;
				if(button == NameRButton) Settings.station_sorting = Compare.NAME;
				if(button == LanguageRButton) Settings.station_sorting = Compare.LANGUAGE;
				if(button == CountryRButton) Settings.station_sorting = Compare.COUNTRY;
				if(button == StateRButton) Settings.station_sorting = Compare.STATE;
				if(button == BitrateRButton) Settings.station_sorting = Compare.BITRATE;
				if(button == ClicksRButton) Settings.station_sorting = Compare.CLICKS;
				App.window.station_sorting_changed();
			}
		}

		[GtkCallback]
		private void SortDescendingButton_toggled(){
			if(SortDescendingButton.active){
				Settings.sort_ascending = false;
				SortAscendingButton.set_active(false);
				SortDescendingButton.set_active(true);
				App.window.station_sorting_changed();
			}
		}

		[GtkCallback]
		private void SortAscendingButton_toggled(){
			if(SortAscendingButton.active){
				Settings.sort_ascending = true;
				SortDescendingButton.set_active(false);
				SortAscendingButton.set_active(true);
				App.window.station_sorting_changed();
			}
		}
	}
}
