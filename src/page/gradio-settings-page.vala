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
		private GroupBox playback_group;
		private GroupBox library_group;
		private GroupBox features_group;
		private GroupBox cache_group;


		public SettingsPage () {
			setup_groups();
			setup_items();
			this.show_all();
		}

		private void setup_groups(){
			features_group = new GroupBox(_("Features"));
			SettingsBox.add(features_group);

			playback_group = new GroupBox(_("Playback"));
			SettingsBox.add(playback_group);

			appearance_group = new GroupBox(_("Appearance"));
			SettingsBox.add(appearance_group);

			cache_group = new GroupBox(_("Cache"));
			SettingsBox.add(cache_group);
		}

		private void setup_items(){
			// APPEARANCE

			// Dark design
			SwitchItem use_dark_design_switch = new SwitchItem(_("Prefer dark theme"), _("Use a dark theme, if possible"));
			use_dark_design_switch.set_state(App.settings.enable_dark_theme);
			use_dark_design_switch.toggled.connect(() => {App.settings.enable_dark_theme = use_dark_design_switch.get_state();});
			appearance_group.add_listbox_row(use_dark_design_switch);


			// PLAYBACK

			// enable background playback
			SwitchItem enable_background_playback_switch = new SwitchItem(_("Background Playback"), _("Continue the playback if you close the Gradio window"));
			enable_background_playback_switch.set_state(App.settings.enable_background_playback);
			enable_background_playback_switch.toggled.connect(() => {App.settings.enable_background_playback = enable_background_playback_switch.get_state();});
			playback_group.add_listbox_row(enable_background_playback_switch);

			// resume playback on startup
			SwitchItem resume_playback_on_startup_switch = new SwitchItem(_("Resume playback on startup"), _("Play the latest station if you start Gradio"));
			resume_playback_on_startup_switch.set_state(App.settings.resume_playback_on_startup);
			resume_playback_on_startup_switch.toggled.connect(() => {App.settings.resume_playback_on_startup = resume_playback_on_startup_switch.get_state();});
			playback_group.add_listbox_row(resume_playback_on_startup_switch);


			// FEATURES

			// mpris
			SwitchItem enable_mpris_switch = new SwitchItem(_("MPRIS"), _("Integrate Gradio as media player in your desktop environment"));
			enable_mpris_switch.set_state(App.settings.enable_mpris);
			enable_mpris_switch.toggled.connect(() => {App.settings.enable_mpris = enable_mpris_switch.get_state();});
			features_group.add_listbox_row(enable_mpris_switch);

			// enable notifications
			SwitchItem enable_notifications_switch = new SwitchItem(_("Notifications"), _("Show desktop notifications"));
			enable_notifications_switch.set_state(App.settings.enable_notifications);
			enable_notifications_switch.toggled.connect(() => {App.settings.enable_notifications = enable_notifications_switch.get_state();});
			features_group.add_listbox_row(enable_notifications_switch);

			// enable tray icon
			SwitchItem enable_tray_icon_switch = new SwitchItem(_("Tray icon"), _("Show a tray icon, to restore the main window"));
			enable_tray_icon_switch.set_state(App.settings.enable_tray_icon);
			enable_tray_icon_switch.toggled.connect(() => {App.settings.enable_tray_icon = enable_tray_icon_switch.get_state();});
			features_group.add_listbox_row(enable_tray_icon_switch);


			// CACHE

			// cache station images
			SwitchItem cache_stations_switch = new SwitchItem(_("Cache station icons"), _("Saves the images locally."));
			cache_stations_switch.set_state(App.settings.enable_caching);
			cache_stations_switch.toggled.connect(() => {App.settings.enable_caching = cache_stations_switch.get_state();});
			cache_group.add_listbox_row(cache_stations_switch);

			ButtonItem clear_cache_button = new ButtonItem(_("Clear Cache"), _("Clear all cached station icons"));
			clear_cache_button.btn_clicked.connect(() => {
				App.image_cache.clear_cache.begin((obj,res) => {
					Util.show_info_dialog("Successfully cleared cache data", App.window);
				});
			});
			cache_group.add_listbox_row(clear_cache_button);

		}

		public string get_title(){
			return _("Settings");
		}

	}
}

