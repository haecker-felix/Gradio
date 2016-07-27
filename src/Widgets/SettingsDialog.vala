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

		private GLib.Settings settings;

		public SettingsDialog () {
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
				} else {
					settings.set_boolean ("use-dark-design", false);
				}
				
			});

			LoadPicturesSwitch.notify["active"].connect (() => {
				if (LoadPicturesSwitch.active) {
					settings.set_boolean ("load-pictures", true);
				} else {
					settings.set_boolean ("load-pictures", false);
				}
				
			});

		}

		private void load_settings(GLib.Settings settings){
			UseDarkDesignSwitch.set_active(settings.get_boolean ("use-dark-design"));
			LoadPicturesSwitch.set_active(settings.get_boolean ("load-pictures"));
			OnlyShowWorkingStationsSwitch.set_active(settings.get_boolean ("only-show-working-stations"));
		}

	}
}
