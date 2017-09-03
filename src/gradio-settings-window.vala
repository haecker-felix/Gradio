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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/settings-window.ui")]
	public class SettingsWindow : Gtk.Window {

		[GtkChild] private Box SettingsBox;

		private GroupBox appearance_group;
		private GroupBox playback_group;
		private GroupBox library_group;
		private GroupBox features_group;
		private GroupBox cache_group;


		public SettingsWindow () {
			setup_groups();
			setup_items();
		}

		private void setup_groups(){
			features_group = new GroupBox(_("Features"));
			SettingsBox.add(features_group);

			playback_group = new GroupBox(_("Playback"));
			SettingsBox.add(playback_group);

			library_group = new GroupBox(_("Library"));
			SettingsBox.add(library_group);

			appearance_group = new GroupBox(_("Appearance"));
			SettingsBox.add(appearance_group);

			cache_group = new GroupBox(_("Cache"));
			SettingsBox.add(cache_group);
		}

		private void setup_items(){
			// APPEARANCE

			// Dark design
			SwitchItem use_dark_design_switch = new SwitchItem(_("Prefer dark theme"), _("Use a dark theme, if possible"));
			use_dark_design_switch.set_state(Settings.enable_dark_theme);
			use_dark_design_switch.toggled.connect(() => {Settings.enable_dark_theme = use_dark_design_switch.get_state();});
			appearance_group.add_listbox_row(use_dark_design_switch);

			// hide broken stations
			SwitchItem hide_broken_stations_switch = new SwitchItem(_("Hide broken stations"), _("Don't show stations, which are not working"));
			hide_broken_stations_switch.set_state(Settings.hide_broken_stations);
			hide_broken_stations_switch.toggled.connect(() => {Settings.hide_broken_stations = hide_broken_stations_switch.get_state();});
			appearance_group.add_listbox_row(hide_broken_stations_switch);


			// PLAYBACK

			// enable background playback
			SwitchItem enable_background_playback_switch = new SwitchItem(_("Background Playback"), _("Continue the playback if you close the Gradio window"));
			enable_background_playback_switch.set_state(Settings.enable_background_playback);
			enable_background_playback_switch.toggled.connect(() => {Settings.enable_background_playback = enable_background_playback_switch.get_state();});
			playback_group.add_listbox_row(enable_background_playback_switch);

			// resume playback on startup
			SwitchItem resume_playback_on_startup_switch = new SwitchItem(_("Resume playback on startup"), _("Play the latest station if you start Gradio"));
			resume_playback_on_startup_switch.set_state(Settings.resume_playback_on_startup);
			resume_playback_on_startup_switch.toggled.connect(() => {Settings.resume_playback_on_startup = resume_playback_on_startup_switch.get_state();});
			playback_group.add_listbox_row(resume_playback_on_startup_switch);


			// LIBRARY

			// import library
			ButtonItem import_library_button = new ButtonItem(_("Import"), _("Replace the current library with a another one"));
			import_library_button.btn_clicked.connect(() => {
				string path = Util.open_file(_("Select database to import"), _("Import"), this);
				if(path == "") return;
				if(!Util.show_yes_no_dialog(_("Do you want to replace the current library with this one?"), this))return;
				App.library.import_database(path);
			});
			library_group.add_listbox_row(import_library_button);

			// export library
			ButtonItem export_library_button = new ButtonItem(_("Export"), _("Export the current library"));
			export_library_button.btn_clicked.connect(() => {
				string path = Util.save_file(_("Export library"), _("Export"), this);
				if(path == "") return;
				App.library.export_database(path);
			});
			library_group.add_listbox_row(export_library_button);


			// FEATURES

			// mpris
			SwitchItem enable_mpris_switch = new SwitchItem(_("MPRIS"), _("Integrate Gradio as media player in your desktop environment"));
			enable_mpris_switch.set_state(Settings.enable_mpris);
			enable_mpris_switch.toggled.connect(() => {Settings.enable_mpris = enable_mpris_switch.get_state();});
			features_group.add_listbox_row(enable_mpris_switch);

			// enable notifications
			SwitchItem enable_notifications_switch = new SwitchItem(_("Notifications"), _("Show desktop notifications"));
			enable_notifications_switch.set_state(Settings.enable_notifications);
			enable_notifications_switch.toggled.connect(() => {Settings.enable_notifications = enable_notifications_switch.get_state();});
			features_group.add_listbox_row(enable_notifications_switch);


			// CACHE

			// cache station images
			SwitchItem cache_stations_switch = new SwitchItem(_("Cache station icons"), _("Saves the images locally."));
			cache_stations_switch.set_state(Settings.enable_caching);
			cache_stations_switch.toggled.connect(() => {Settings.enable_caching = cache_stations_switch.get_state();});
			cache_group.add_listbox_row(cache_stations_switch);

			ButtonItem clear_cache_button = new ButtonItem(_("Clear Cache"), _("Clear all cached station icons"));
			clear_cache_button.btn_clicked.connect(() => {App.image_cache.clear_cache.begin();});
			cache_group.add_listbox_row(clear_cache_button);

		}

	}
}
