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

		private GLib.Settings settings;

		public SettingsDialog () {
			var gtk_settings = Gtk.Settings.get_default ();
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			load_settings(settings);

			OnlyShowWorkingStationsSwitch.notify["active"].connect (() => {
				if (OnlyShowWorkingStationsSwitch.active) {
					settings.set_boolean ("only-show-working-stations", true);
				} else {
					settings.set_boolean ("only-show-working-stations", false);
				}

			});

			UseDarkDesignSwitch.notify["active"].connect (() => {
				if (UseDarkDesignSwitch.active) {
					settings.set_boolean ("use-dark-design", true);
					gtk_settings.gtk_application_prefer_dark_theme = true;
				} else {
					settings.set_boolean ("use-dark-design", false);
					gtk_settings.gtk_application_prefer_dark_theme = false;
				}
				
			});

			LoadPicturesSwitch.notify["active"].connect (() => {
				if (LoadPicturesSwitch.active) {
					settings.set_boolean ("load-pictures", true);
				} else {
					settings.set_boolean ("load-pictures", false);
				}
				
			});

			CloseToTraySwitch.notify["active"].connect (() => {
				if (CloseToTraySwitch.active) {
					settings.set_boolean ("close-to-tray", true);
				} else {
					settings.set_boolean ("close-to-tray", false);
				}
				
			});

		}

		private void load_settings(GLib.Settings settings){
			UseDarkDesignSwitch.set_active(settings.get_boolean ("use-dark-design"));
			LoadPicturesSwitch.set_active(settings.get_boolean ("load-pictures"));
			OnlyShowWorkingStationsSwitch.set_active(settings.get_boolean ("only-show-working-stations"));
			CloseToTraySwitch.set_active(settings.get_boolean ("close-to-tray"));
		}

	}
}
