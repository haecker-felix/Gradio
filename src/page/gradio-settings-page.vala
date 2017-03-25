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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/page/settings-page.ui")]
	public class SettingsPage : Gtk.Box, Page {

		[GtkChild] private Box SettingsBox;

		private GroupBox appearance_group;
		private GroupBox notifications_group;
		private GroupBox playback_group;
		private GroupBox behavior_group;
		private GroupBox features_group;


		public SettingsPage () {
			setup_view();
			load_settings();
		}

		private void setup_view(){
			setup_groups();
			setup_items();
		}

		private void setup_groups(){
			behavior_group = new GroupBox("Behaviour");
			SettingsBox.add(behavior_group);

			features_group = new GroupBox("Features");
			SettingsBox.add(features_group);

			playback_group = new GroupBox("Playback");
			SettingsBox.add(playback_group);

			appearance_group = new GroupBox("Appearance");
			SettingsBox.add(appearance_group);

			notifications_group = new GroupBox("Notifications");
			SettingsBox.add(notifications_group);
		}

		private void setup_items(){
			// APPEARANCE

			// Dark design
			SwitchItem use_dark_design_switch = new SwitchItem("Dark Theme", "Whether Gradio should use a dark theme");
			use_dark_design_switch.set_state(Settings.enable_dark_design);
			use_dark_design_switch.toggled.connect(() => {Settings.enable_dark_design = use_dark_design_switch.get_state();});
			appearance_group.add_listbox_row(use_dark_design_switch);

			// Show station icons
			SwitchItem show_station_icons_switch = new SwitchItem("Show station icons", "Load the station icon from the internet");
			show_station_icons_switch.set_state(Settings.show_station_icons);
			show_station_icons_switch.toggled.connect(() => {Settings.show_station_icons = show_station_icons_switch.get_state();});
			appearance_group.add_listbox_row(show_station_icons_switch);

			// hide broken stations
			SwitchItem hide_broken_stations_switch = new SwitchItem("Hide broken stations", "Don't show stations, which are not working");
			hide_broken_stations_switch.set_state(Settings.hide_broken_stations);
			hide_broken_stations_switch.toggled.connect(() => {Settings.hide_broken_stations = hide_broken_stations_switch.get_state();});
			appearance_group.add_listbox_row(hide_broken_stations_switch);


			// NOTIFICATIONS

			// enable notifications
			SwitchItem show_notifications_switch = new SwitchItem("Notifications", "Show desktop notifications");
			show_notifications_switch.set_state(Settings.show_notifications);
			show_notifications_switch.toggled.connect(() => {Settings.show_notifications = show_notifications_switch.get_state();});
			notifications_group.add_listbox_row(show_notifications_switch);


			// PLAYBACK

			// enable background playback
			SwitchItem enable_background_playback_switch = new SwitchItem("Background Playback", "Continue the playback if you close the Gradio window");
			enable_background_playback_switch.set_state(Settings.enable_background_playback);
			enable_background_playback_switch.toggled.connect(() => {Settings.enable_background_playback = enable_background_playback_switch.get_state();});
			playback_group.add_listbox_row(enable_background_playback_switch);

			// resume playback on startup
			SwitchItem resume_playback_on_startup_switch = new SwitchItem("Resume playback on startup", "Play the latest station if you start Gradio");
			resume_playback_on_startup_switch.set_state(Settings.resume_playback_on_startup);
			resume_playback_on_startup_switch.toggled.connect(() => {Settings.resume_playback_on_startup = resume_playback_on_startup_switch.get_state();});
			playback_group.add_listbox_row(resume_playback_on_startup_switch);


			// BEHAVIOUR

			// close to tray icon
			SwitchItem enable_close_to_tray_switch = new SwitchItem("Close to tray icon", "Close the Gradio window, and a tray icon will appear");
			enable_close_to_tray_switch.set_state(Settings.enable_close_to_tray);
			enable_close_to_tray_switch.toggled.connect(() => {Settings.enable_close_to_tray = enable_close_to_tray_switch.get_state();});
			behavior_group.add_listbox_row(enable_close_to_tray_switch);


			// FEATURES

			// mpris
			SwitchItem enable_mpris_switch = new SwitchItem("MPRIS", "Integrate Gradio as media player in your desktop environment");
			enable_mpris_switch.set_state(Settings.enable_mpris);
			enable_mpris_switch.toggled.connect(() => {Settings.enable_mpris = enable_mpris_switch.get_state();});
			features_group.add_listbox_row(enable_mpris_switch);

		}

		private void load_settings(){
			// ResumePlaybackOnStartup.set_active(Settings.resume_playback_on_startup);
		}

	}
}
