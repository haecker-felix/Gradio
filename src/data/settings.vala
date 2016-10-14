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

		public static bool show_notifications{
			get{
				return Gradio.App.settings.get_boolean ("show-notifications");
			}
			set{
				Gradio.App.settings.set_boolean ("show-notifications", value);
			}
		}

		public static bool enable_dark_design{
			get{
				return Gradio.App.settings.get_boolean ("use-dark-design");
			}
			set{
				var gtk_settings = Gtk.Settings.get_default ();
				gtk_settings.gtk_application_prefer_dark_theme = value;
				Gradio.App.settings.set_boolean ("use-dark-design", value);
			}
		}

		public static bool enable_mpris{
			get{
				return Gradio.App.settings.get_boolean ("enable-mpris");
			}
			set{
				Gradio.App.settings.set_boolean ("enable-mpris", value);
			}
		}

		public static bool enable_background_playback{
			get{
				return Gradio.App.settings.get_boolean ("enable-background-playback");
			}
			set{
				Gradio.App.settings.set_boolean ("enable-background-playback", value);
			}
		}

		public static bool enable_close_to_tray{
			get{
				return Gradio.App.settings.get_boolean ("close-to-tray");
			}
			set{
				Gradio.App.settings.set_boolean ("close-to-tray", value);
			}
		}

		public static bool show_languages_c{
			get{
				return Gradio.App.settings.get_boolean ("show-languages-category");
			}
			set{
				Gradio.App.settings.set_boolean ("show-languages-category", value);
			}
		}

		public static bool show_codecs_c{
			get{
				return Gradio.App.settings.get_boolean ("show-codecs-category");
			}
			set{
				Gradio.App.settings.set_boolean ("show-codecs-category", value);
			}
		}

		public static bool show_countries_c{
			get{
				return Gradio.App.settings.get_boolean ("show-countries-category");
			}
			set{
				Gradio.App.settings.set_boolean ("show-countries-category", value);
			}
		}

		public static bool show_tags_c{
			get{
				return Gradio.App.settings.get_boolean ("show-tags-category");
			}
			set{
				Gradio.App.settings.set_boolean ("show-tags-category", value);
			}
		}

		public static bool show_states_c{
			get{
				return Gradio.App.settings.get_boolean ("show-states-category");
			}
			set{
				Gradio.App.settings.set_boolean ("show-states-category", value);
			}
		}

		public static bool show_station_icons{
			get{
				return Gradio.App.settings.get_boolean ("load-pictures");
			}
			set{
				Gradio.App.settings.set_boolean ("load-pictures", value);
			}
		}

		public static bool hide_broken_stations{
			get{
				return Gradio.App.settings.get_boolean ("only-show-working-stations");
			}
			set{
				Gradio.App.settings.set_boolean ("only-show-working-stations", value);
			}
		}

		public static bool resume_playback_on_startup{
			get{
				return Gradio.App.settings.get_boolean ("resume-playback-on-startup");
			}
			set{
				Gradio.App.settings.set_boolean ("resume-playback-on-startup", value);
			}
		}

		public static int previous_station{
			get{
				return Gradio.App.settings.get_int ("previous-station");
			}
			set{
				Gradio.App.settings.set_int ("previous-station", value);
			}
		}

	}
}
