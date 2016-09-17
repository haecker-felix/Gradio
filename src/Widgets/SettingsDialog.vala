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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/settings-dialog.ui")]
	public class SettingsDialog : Gtk.Dialog {

		[GtkChild]
		private Switch OnlyShowWorkingStationsSwitch;
		[GtkChild]
		private Switch UseDarkDesignSwitch;
		[GtkChild]
		private Switch LoadPicturesSwitch;
		[GtkChild]
		private Switch CloseToTraySwitch;
		[GtkChild]
		private Switch ShowNotificationsSwitch;


		public SettingsDialog () {
			load_settings();
			var gtk_settings = Gtk.Settings.get_default ();


			OnlyShowWorkingStationsSwitch.notify["active"].connect (() => {
				if (OnlyShowWorkingStationsSwitch.active) {
					Gradio.App.settings.set_boolean ("only-show-working-stations", true);
				} else {
					Gradio.App.settings.set_boolean ("only-show-working-stations", false);
				}

			});

			UseDarkDesignSwitch.notify["active"].connect (() => {
				if (UseDarkDesignSwitch.active) {
					Gradio.App.settings.set_boolean ("use-dark-design", true);
					gtk_settings.gtk_application_prefer_dark_theme = true;
				} else {
					Gradio.App.settings.set_boolean ("use-dark-design", false);
					gtk_settings.gtk_application_prefer_dark_theme = false;
				}

			});

			LoadPicturesSwitch.notify["active"].connect (() => {
				if (LoadPicturesSwitch.active) {
					Gradio.App.settings.set_boolean ("load-pictures", true);
				} else {
					Gradio.App.settings.set_boolean ("load-pictures", false);
				}
				
			});

			CloseToTraySwitch.notify["active"].connect (() => {
				if (CloseToTraySwitch.active) {
					Gradio.App.settings.set_boolean ("close-to-tray", true);
				} else {
					Gradio.App.settings.set_boolean ("close-to-tray", false);
				}
				
			});

			ShowNotificationsSwitch.notify["active"].connect (() => {
				if (ShowNotificationsSwitch.active) {
					Gradio.App.settings.set_boolean ("show-notifications", true);
				} else {
					Gradio.App.settings.set_boolean ("show-notifications", false);
				}
				
			});

		}

		private void load_settings(){
			UseDarkDesignSwitch.set_active(Gradio.App.settings.get_boolean ("use-dark-design"));
			LoadPicturesSwitch.set_active(Gradio.App.settings.get_boolean ("load-pictures"));
			OnlyShowWorkingStationsSwitch.set_active(Gradio.App.settings.get_boolean ("only-show-working-stations"));
			CloseToTraySwitch.set_active(Gradio.App.settings.get_boolean ("close-to-tray"));
			ShowNotificationsSwitch.set_active(Gradio.App.settings.get_boolean ("show-notifications"));
		}

	}
}
