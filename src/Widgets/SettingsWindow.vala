using Gtk;
namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/settings-window.ui")]
	public class SettingsWindow : Gtk.Window {

		[GtkChild]
		private Switch OnlyShowWorkingStationsSwitch;
		[GtkChild]
		private Switch UseDarkDesignSwitch;
		[GtkChild]
		private Switch ShowNotificationsSwitch;

		public SettingsWindow (GradioApp app) {
			load_settings(app.settings);

			OnlyShowWorkingStationsSwitch.notify["active"].connect (() => {
				if (OnlyShowWorkingStationsSwitch.active) {
					app.settings.set_boolean ("only-show-working-stations", true);
				} else {
					app.settings.set_boolean ("only-show-working-stations", false);
				}
				
			});

			UseDarkDesignSwitch.notify["active"].connect (() => {
				if (UseDarkDesignSwitch.active) {
					app.settings.set_boolean ("use-dark-design", true);
				} else {
					app.settings.set_boolean ("use-dark-design", false);
				}
				
			});

			ShowNotificationsSwitch.notify["active"].connect (() => {
				if (ShowNotificationsSwitch.active) {
					app.settings.set_boolean ("show-notifications", true);
				} else {
					app.settings.set_boolean ("show-notifications", false);
				}
				
			});

		}

		private void load_settings(GLib.Settings settings){
			UseDarkDesignSwitch.set_active(settings.get_boolean ("use-dark-design"));
			ShowNotificationsSwitch.set_active(settings.get_boolean ("show-notifications"));
			OnlyShowWorkingStationsSwitch.set_active(settings.get_boolean ("only-show-working-stations"));
		}

	}
}
