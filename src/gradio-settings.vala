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

	public class Settings : Object{

		private static GLib.Settings settings;

		private static bool _enable_notifications;
		private static bool _enable_dark_theme;
		private static bool _enable_mpris;
		private static bool _enable_background_playback;
		private static bool _enable_caching;
		private static bool _resume_playback_on_startup;
		private static bool _hide_broken_stations;
		private static int _previous_station;
		private static double _volume_position;
		private static int _window_height;
		private static int _window_width;
		private static int _window_position_x;
		private static int _window_position_y;
		private static int _icon_zoom;

		static construct{
			settings = new GLib.Settings ("de.haeckerfelix.gradio");

			_enable_notifications = settings.get_boolean("enable-notifications");
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
			_window_position_x = settings.get_int("window-position-x");
			_window_position_y = settings.get_int("window-position-y");
			_icon_zoom = settings.get_int("icon-zoom");
		}


		public static bool enable_notifications{
			get{
				return _enable_notifications;
			}
			set{
				enable_notifications = value;
				settings.set_boolean ("enable-notifications", value);
			}
		}

		public static bool enable_dark_theme{
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

		public static bool enable_mpris{
			get{
				return _enable_mpris;
			}
			set{
				_enable_mpris = value;
				settings.set_boolean ("enable-mpris", value);
			}
		}

		public static bool enable_background_playback{
			get{
				return _enable_background_playback;
			}
			set{
				_enable_background_playback = value;
				settings.set_boolean ("enable-background-playback", value);
			}
		}

		public static bool enable_caching{
			get{
				return _enable_caching;
			}
			set{
				_enable_caching = value;
				settings.set_boolean ("enable-caching", value);
			}
		}

		public static bool resume_playback_on_startup{
			get{
				return _resume_playback_on_startup;
			}
			set{
				_resume_playback_on_startup = value;
				settings.set_boolean ("resume-playback-on-startup", value);
			}
		}

		public static bool hide_broken_stations{
			get{
				return _hide_broken_stations;
			}
			set{
				_hide_broken_stations = value;
				settings.set_boolean ("hide-broken-stations", value);
			}
		}

		public static int previous_station{
			get{
				return _previous_station;
			}
			set{
				_previous_station = value;
				settings.set_int ("previous-station", value);
			}
		}

		public static double volume_position{
			get{
				return _volume_position;
			}
			set{
				_volume_position = value;
				settings.set_double ("volume-position", value);
			}
		}

		public static int window_height{
			get{
				return _window_height;
			}
			set{
				_window_height = value;
				settings.set_int ("window-height", value);
			}
		}

		public static int window_width{
			get{
				return _window_width;
			}
			set{
				_window_width = value;
				settings.set_int ("window-width", value);
			}
		}

		public static int window_position_x{
			get{
				return _window_position_x;
			}
			set{
				_window_position_x = value;
				settings.set_int ("window-position-x", value);
			}
		}

		public static int window_position_y{
			get{
				return _window_position_y;
			}
			set{
				_window_position_y = value;
				settings.set_int ("window-position-y", value);
			}
		}

		public static int icon_zoom{
			get{
				return _icon_zoom;
			}
			set{
				_icon_zoom = value;
				settings.set_int ("icon-zoom", value);
			}
		}

	}
}
