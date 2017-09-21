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

	public class Settings : GLib.Object{

		private GLib.Settings settings;

		private bool _enable_notifications;
		private bool _enable_tray_icon;
		private bool _enable_dark_theme;
		private bool _enable_mpris;
		private bool _enable_background_playback;
		private bool _enable_caching;
		private bool _resume_playback_on_startup;
		private bool _hide_broken_stations;
		private int _previous_station;
		private double _volume_position;
		private int _window_height;
		private int _window_width;
		private int _icon_zoom;
		private Compare _station_sorting;
		private bool _sort_ascending;
		private int _max_search_results;

		public Settings(){
			settings = new GLib.Settings ("de.haeckerfelix.gradio");

			_enable_notifications = settings.get_boolean("enable-notifications");
			_enable_tray_icon = settings.get_boolean("enable-tray-icon");
			_enable_dark_theme = settings.get_boolean("enable-dark-theme");
			_enable_mpris = settings.get_boolean("enable-mpris");
			_enable_background_playback = settings.get_boolean("enable-background-playback");
			_enable_caching = settings.get_boolean("enable-caching");
			_resume_playback_on_startup = settings.get_boolean("resume-playback-on-startup");
			_hide_broken_stations = settings.get_boolean("hide-broken-stations");
			_previous_station = settings.get_int("previous-station");
			_volume_position = settings.get_double("volume-position");
			_window_height = settings.get_int("window-height");
			_window_width = settings.get_int("window-width");
			_icon_zoom = settings.get_int("icon-zoom");
			_station_sorting = (Compare) settings.get_int("station-sorting");
			_sort_ascending = settings.get_boolean("sort-ascending");
			_max_search_results = settings.get_int("max-search-results");
		}


		public bool enable_notifications{
			get{
				return _enable_notifications;
			}
			set{
				_enable_notifications = value;
				settings.set_boolean ("enable-notifications", value);
			}
		}

		public bool enable_tray_icon{
			get{
				return _enable_tray_icon;
			}
			set{
				_enable_tray_icon = value;
				App.window.show_tray_icon(value);
				settings.set_boolean ("enable-tray-icon", value);
			}
		}

		public bool enable_dark_theme{
			get{
				return _enable_dark_theme;
			}
			set{
				_enable_dark_theme = value;
				var gtk_settings = Gtk.Settings.get_default ();
				gtk_settings.gtk_application_prefer_dark_theme = value;
				settings.set_boolean ("enable-dark-theme", value);
			}
		}

		public bool enable_mpris{
			get{
				return _enable_mpris;
			}
			set{
				_enable_mpris = value;
				settings.set_boolean ("enable-mpris", value);
			}
		}

		public bool enable_background_playback{
			get{
				return _enable_background_playback;
			}
			set{
				_enable_background_playback = value;
				settings.set_boolean ("enable-background-playback", value);
			}
		}

		public bool enable_caching{
			get{
				return _enable_caching;
			}
			set{
				_enable_caching = value;
				settings.set_boolean ("enable-caching", value);
			}
		}

		public bool resume_playback_on_startup{
			get{
				return _resume_playback_on_startup;
			}
			set{
				_resume_playback_on_startup = value;
				settings.set_boolean ("resume-playback-on-startup", value);
			}
		}

		public bool hide_broken_stations{
			get{
				return _hide_broken_stations;
			}
			set{
				_hide_broken_stations = value;
				settings.set_boolean ("hide-broken-stations", value);
			}
		}

		public int previous_station{
			get{
				return _previous_station;
			}
			set{
				_previous_station = value;
				settings.set_int ("previous-station", value);
			}
		}

		public double volume_position{
			get{
				return _volume_position;
			}
			set{
				_volume_position = value;
				settings.set_double ("volume-position", value);
			}
		}

		public int window_height{
			get{
				return _window_height;
			}
			set{
				_window_height = value;
				settings.set_int ("window-height", value);
			}
		}

		public int window_width{
			get{
				return _window_width;
			}
			set{
				_window_width = value;
				settings.set_int ("window-width", value);
			}
		}

		public int icon_zoom{
			get{
				return _icon_zoom;
			}
			set{
				_icon_zoom = value;
				settings.set_int ("icon-zoom", value);
			}
		}

		public Compare station_sorting{
			get{
				return _station_sorting;
			}
			set{
				_station_sorting = value;
				settings.set_int ("station-sorting", _station_sorting);
			}
		}

		public bool sort_ascending{
			get{
				return _sort_ascending;
			}
			set{
				_sort_ascending = value;
				settings.set_boolean ("sort-ascending", _sort_ascending);
			}
		}

		public int max_search_results{
			get{
				return _max_search_results;
			}
			set{
				_max_search_results = value;
				settings.set_int ("max-search-results", _max_search_results);
			}
		}
	}
}
