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
		[GtkChild]
		private Switch ShowNotificationsSwitch;


		public SettingsDialog () {
			load_settings();
			var gtk_settings = Gtk.Settings.get_default ();


			OnlyShowWorkingStationsSwitch.notify["active"].connect (() => {
				if (OnlyShowWorkingStationsSwitch.active) {
					Gradio.App.settings.set_boolean ("only-show-working-stations", true);
				} else {
					Gradio.App.settings.set_boolean ("only-show-working-stations", false);
				}

			});

			UseDarkDesignSwitch.notify["active"].connect (() => {
				if (UseDarkDesignSwitch.active) {
					Gradio.App.settings.set_boolean ("use-dark-design", true);
					gtk_settings.gtk_application_prefer_dark_theme = true;
				} else {
					Gradio.App.settings.set_boolean ("use-dark-design", false);
					gtk_settings.gtk_application_prefer_dark_theme = false;
				}

			});

			LoadPicturesSwitch.notify["active"].connect (() => {
				if (LoadPicturesSwitch.active) {
					Gradio.App.settings.set_boolean ("load-pictures", true);
				} else {
					Gradio.App.settings.set_boolean ("load-pictures", false);
				}
				
			});

			CloseToTraySwitch.notify["active"].connect (() => {
				if (CloseToTraySwitch.active) {
					Gradio.App.settings.set_boolean ("close-to-tray", true);
				} else {
					Gradio.App.settings.set_boolean ("close-to-tray", false);
				}
				
			});

			ShowNotificationsSwitch.notify["active"].connect (() => {
				if (ShowNotificationsSwitch.active) {
					Gradio.App.settings.set_boolean ("show-notifications", true);
				} else {
					Gradio.App.settings.set_boolean ("show-notifications", false);
				}
				
			});

		}

		private void load_settings(){
			UseDarkDesignSwitch.set_active(Gradio.App.settings.get_boolean ("use-dark-design"));
			LoadPicturesSwitch.set_active(Gradio.App.settings.get_boolean ("load-pictures"));
			OnlyShowWorkingStationsSwitch.set_active(Gradio.App.settings.get_boolean ("only-show-working-stations"));
			CloseToTraySwitch.set_active(Gradio.App.settings.get_boolean ("close-to-tray"));
			ShowNotificationsSwitch.set_active(Gradio.App.settings.get_boolean ("show-notifications"));
		}

	}
}
