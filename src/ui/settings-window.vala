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
	public class SettingsWindow : Gtk.Window {

		[GtkChild]
		private CheckButton EnableNotifications;
		[GtkChild]
		private CheckButton EnableMPRIS;
		[GtkChild]
		private CheckButton UseDarkDesign;
		[GtkChild]
		private CheckButton EnableBackgroundPlayback;
		[GtkChild]
		private CheckButton EnableMinimizeToTray;
		[GtkChild]
		private CheckButton ShowLanguagesC;
		[GtkChild]
		private CheckButton ShowCodecsC;
		[GtkChild]
		private CheckButton ShowCountriesC;
		[GtkChild]
		private CheckButton ShowTagsC;
		[GtkChild]
		private CheckButton ShowStatesC;
		[GtkChild]
		private CheckButton ShowStationIcons;
		[GtkChild]
		private CheckButton HideBrokenStations;

		public SettingsWindow () {
			load_settings();

			EnableNotifications.toggled.connect(() => SettingsManager.show_notifications = EnableNotifications.get_active());
			EnableMPRIS.toggled.connect(() => SettingsManager.enable_mpris = EnableMPRIS.get_active());
			UseDarkDesign.toggled.connect(() => SettingsManager.enable_dark_design = UseDarkDesign.get_active());
			EnableBackgroundPlayback.toggled.connect(() => SettingsManager.enable_background_playback = EnableBackgroundPlayback.get_active());
			EnableMinimizeToTray.toggled.connect(() => SettingsManager.enable_close_to_tray = EnableMinimizeToTray.get_active());
			ShowLanguagesC.toggled.connect(() => SettingsManager.show_languages_c = ShowLanguagesC.get_active());
			ShowCodecsC.toggled.connect(() => SettingsManager.show_codecs_c = ShowCodecsC.get_active());
			ShowCountriesC.toggled.connect(() => SettingsManager.show_countries_c = ShowCountriesC.get_active());
			ShowTagsC.toggled.connect(() => SettingsManager.show_tags_c = ShowTagsC.get_active());
			ShowStatesC.toggled.connect(() => SettingsManager.show_states_c = ShowStatesC.get_active());
			ShowStationIcons.toggled.connect(() => SettingsManager.show_station_icons = ShowStationIcons.get_active());
			HideBrokenStations.toggled.connect(() => SettingsManager.hide_broken_stations = HideBrokenStations.get_active());
		}

		private void load_settings(){
			EnableNotifications.set_active(SettingsManager.show_notifications);
			EnableMPRIS.set_active(SettingsManager.enable_mpris);
			UseDarkDesign.set_active(SettingsManager.enable_dark_design);
			EnableBackgroundPlayback.set_active(SettingsManager.enable_background_playback);
			EnableMinimizeToTray.set_active(SettingsManager.enable_close_to_tray);
			ShowLanguagesC.set_active(SettingsManager.show_languages_c);
			ShowCodecsC.set_active(SettingsManager.show_codecs_c);
			ShowCountriesC.set_active(SettingsManager.show_countries_c);
			ShowStatesC.set_active(SettingsManager.show_states_c);
			ShowTagsC.set_active(SettingsManager.show_tags_c);
			ShowStationIcons.set_active(SettingsManager.show_station_icons);
			HideBrokenStations.set_active(SettingsManager.hide_broken_stations);
		}

	}
}
