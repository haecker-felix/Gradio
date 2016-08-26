using Gst.PbUtils;

namespace Gradio{

	public class Codec{
		public Codec(){
			init();
		}

		public void install_missing_codec(Gst.Message m){
			string description = Gst.PbUtils.missing_plugin_message_get_description (m);
			string[] installer_detail = {Gst.PbUtils.missing_plugin_message_get_installer_detail (m)};

			message("Try to install %s", description);

			if(Gst.PbUtils.install_plugins_supported()){
				var context = new Gst.PbUtils.InstallPluginsContext();
				context.set_desktop_id("de.haeckerfelix.gradio.desktop");

				Gst.PbUtils.install_plugins_async(installer_detail, context, install_callback);
			}else{
				warning("Installation failed. Codec installation is not supported by your distribution. Please install the missin codec by yourself.");
				Util.show_info_dialog("Automatic codec installation isn't supported by your distribution.\n Please install " + description + " manually.", Gradio.App.window);
			}
		}

		private void install_callback(Gst.PbUtils.InstallPluginsReturn result){
			message("resulted");
			switch(result){
				case Gst.PbUtils.InstallPluginsReturn.SUCCESS: message("SUCCESS"); break;
				case Gst.PbUtils.InstallPluginsReturn.NOT_FOUND: message("NOT_FOUND"); break;
				case Gst.PbUtils.InstallPluginsReturn.ERROR: message("ERROR"); break;
				case Gst.PbUtils.InstallPluginsReturn.PARTIAL_SUCCESS: message("PARTIAL_SUCCESS"); break;
				case Gst.PbUtils.InstallPluginsReturn.USER_ABORT: message("USER_ABORT"); break;
				case Gst.PbUtils.InstallPluginsReturn.CRASHED: message("CRASHED"); break;
				case Gst.PbUtils.InstallPluginsReturn.INVALID: message("INVALID"); break;
				default: message(""); break;
			}
		}

	}
}
