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

		public int actual_zoom = 100;
		private const int min_zoom = 50;
		private const int max_zoom = 175;
		private const int zoom_steps = 25;

		private GLib.SimpleActionGroup action_group;

		public MenuButton(){
			actual_zoom = Gradio.App.settings.icon_zoom;
			if(actual_zoom == max_zoom) ZoomInButton.set_sensitive(false);
			if(actual_zoom == min_zoom) ZoomOutButton.set_sensitive(false);

			action_group = new GLib.SimpleActionGroup ();
			this.insert_action_group ("menu", action_group);
			setup_actions();

			App.settings.notify["station-sorting"].connect(() => {
 				var action = action_group.lookup_action ("sort") as GLib.SimpleAction;
				action.set_state(Util.get_sort_string());
			});

			App.settings.notify["sort-ascending"].connect(() => {
 				var action = action_group.lookup_action ("sortorder") as GLib.SimpleAction;
				action.set_state(Util.get_sortorder_string());
			});

			var context = this.get_style_context();
			context.add_class("image-button");
		}

		private void setup_actions(){
			// Import Library
			var action = new GLib.SimpleAction ("import-library", null);
			action.activate.connect (() => {
				string path = Util.import_library_dialog();
				if(path == "") return;
				if(!Util.show_yes_no_dialog(_("Do you want to replace the current library with this one?"), App.window))return;
				App.library.import_database(path);
			});
			action_group.add_action(action);


			// Export Library
			action = new GLib.SimpleAction ("export-library", null);
			action.activate.connect (() => {
				int result = 0;

				Gtk.MessageDialog msg = new Gtk.MessageDialog (App.window, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Please select export format. The M3U format is compatible with other programs but cannot be re-imported into Gradio. The Gradio database format contains all information and can be imported again."));
				msg.add_button(_("Gradio Database Format"), 1);
				msg.add_button(_("M3U Format"), 2);
				result = msg.run();
				msg.close();
				msg.destroy();

				if(result == 1){
					string path = Util.export_library_dialog("gradio_library.db");
					if(path == "") return;
					App.library.export_database(path);
				}

				if(result == 2){
					string path = Util.export_library_dialog("gradio_library.m3u");
					if(path == "") return;
					App.library.export_as_m3u.begin(path);
				}
			});
			action_group.add_action(action);


			// Create Station
			action = new GLib.SimpleAction ("create-station", null);
			action.activate.connect (() => {
				StationEditorDialog editor_dialog = new StationEditorDialog.create();
				editor_dialog.set_transient_for(App.window);
				editor_dialog.set_modal(true);
				editor_dialog.set_visible(true);
			});
			action_group.add_action(action);


			// Hide broken stations
			var variant = new GLib.Variant.boolean(App.settings.hide_broken_stations);
			action = new SimpleAction.stateful("hide-broken-stations", null, variant);
			action.change_state.connect((action,state) => {
				App.settings.hide_broken_stations = state.get_boolean();
				action.set_state(state);
			});
			action_group.add_action(action);


			// Sorting
			variant = new GLib.Variant.string(Util.get_sort_string());
			action = new SimpleAction.stateful("sort", variant.get_type(), variant);
			action.activate.connect((a,b) => {
				switch(b.get_string()){
					case "votes": App.settings.station_sorting = Compare.VOTES; break;
					case "name": App.settings.station_sorting = Compare.NAME; break;
					case "language": App.settings.station_sorting = Compare.LANGUAGE; break;
					case "country": App.settings.station_sorting = Compare.COUNTRY; break;
					case "state": App.settings.station_sorting = Compare.STATE; break;
					case "bitrate": App.settings.station_sorting = Compare.BITRATE; break;
					case "clicks": App.settings.station_sorting = Compare.CLICKS; break;
					case "clicktimestamp": App.settings.station_sorting = Compare.DATE; break;
				}
				a.set_state(b);
			});
			action_group.add_action(action);


			// Sort order
			variant = new GLib.Variant.string(Util.get_sortorder_string());
			action = new SimpleAction.stateful("sortorder", variant.get_type(), variant);
			action.activate.connect((a,b) => {
				switch(b.get_string()){
					case "ascending": App.settings.sort_ascending = true; break;
					case "descending": App.settings.sort_ascending = false; break;
				}
				a.set_state(b);
			});
			action_group.add_action(action);
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

