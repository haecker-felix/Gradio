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

		public Settings(){
			message("Loaded settings module");
			settings = new GLib.Settings ("de.haecker-felix.gradio");
		}


		public static bool show_notifications{
			get{
				return settings.get_boolean ("show-notifications");
			}
			set{
				settings.set_boolean ("show-notifications", value);
			}
		}

		public static bool enable_dark_design{
			get{
				return settings.get_boolean ("use-dark-design");
			}
			set{
				var gtk_settings = Gtk.Settings.get_default ();
				gtk_settings.gtk_application_prefer_dark_theme = value;
				settings.set_boolean ("use-dark-design", value);
			}
		}

		public static bool enable_mpris{
			get{
				return settings.get_boolean ("enable-mpris");
			}
			set{
				settings.set_boolean ("enable-mpris", value);
			}
		}

		public static bool enable_background_playback{
			get{
				return settings.get_boolean ("enable-background-playback");
			}
			set{
				settings.set_boolean ("enable-background-playback", value);
			}
		}

		public static bool enable_close_to_tray{
			get{
				return settings.get_boolean ("close-to-tray");
			}
			set{
				settings.set_boolean ("close-to-tray", value);
			}
		}

		public static bool show_languages_c{
			get{
				return settings.get_boolean ("show-languages-category");
			}
			set{
				settings.set_boolean ("show-languages-category", value);
			}
		}

		public static bool show_codecs_c{
			get{
				return settings.get_boolean ("show-codecs-category");
			}
			set{
				settings.set_boolean ("show-codecs-category", value);
			}
		}

		public static bool show_countries_c{
			get{
				return settings.get_boolean ("show-countries-category");
			}
			set{
				settings.set_boolean ("show-countries-category", value);
			}
		}

		public static bool show_tags_c{
			get{
				return settings.get_boolean ("show-tags-category");
			}
			set{
				settings.set_boolean ("show-tags-category", value);
			}
		}

		public static bool show_states_c{
			get{
				return settings.get_boolean ("show-states-category");
			}
			set{
				settings.set_boolean ("show-states-category", value);
			}
		}

		public static bool show_station_icons{
			get{
				return settings.get_boolean ("load-pictures");
			}
			set{
				settings.set_boolean ("load-pictures", value);
			}
		}

		public static bool hide_broken_stations{
			get{
				return settings.get_boolean ("only-show-working-stations");
			}
			set{
				settings.set_boolean ("only-show-working-stations", value);
			}
		}

		public static bool resume_playback_on_startup{
			get{
				return settings.get_boolean ("resume-playback-on-startup");
			}
			set{
				settings.set_boolean ("resume-playback-on-startup", value);
			}
		}

		public static int previous_station{
			get{
				return settings.get_int ("previous-station");
			}
			set{
				settings.set_int ("previous-station", value);
			}
		}

		public static bool load_pictures{
			get{
				return settings.get_boolean ("load-pictures");
			}
			set{
				settings.set_boolean ("load-pictures", value);
			}
		}

		public static bool use_grid_view{
			get{
				return settings.get_boolean ("use-grid-view");
			}
			set{
				settings.set_boolean ("use-grid-view", value);
			}
		}

		public static double volume_position{
			get{
				return settings.get_double ("volume-position");
			}
			set{
				settings.set_double ("volume-position", value);
			}
		}

		public static int window_height{
			get{
				return settings.get_int ("window-height");
			}
			set{
				settings.set_int ("window-height", value);
			}
		}

		public static int window_width{
			get{
				return settings.get_int ("window-width");
			}
			set{
				settings.set_int ("window-width", value);
			}
		}

		public static int window_position_x{
			get{
				return settings.get_int ("window-position-x");
			}
			set{
				settings.set_int ("window-position-x", value);
			}
		}

		public static int window_position_y{
			get{
				return settings.get_int ("window-position-y");
			}
			set{
				settings.set_int ("window-position-y", value);
			}
		}

	}
}
