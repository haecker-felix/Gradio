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

				Gst.PbUtils.install_plugins_async(installer_detail, context, install_callback);
			}else{
				warning("Installation failed. Codec installation is not supported by your distribution. Please install the missin codec by yourself.");
				Util.show_info_dialog("Automatic codec installation isn't supported by your distribution.\nPlease install " + description + " manually.", Gradio.App.window);
			}
		}

		private void install_callback(Gst.PbUtils.InstallPluginsReturn result){
			message("resulted");
			switch(result){
				case Gst.PbUtils.InstallPluginsReturn.SUCCESS: close(); break;
				case Gst.PbUtils.InstallPluginsReturn.PARTIAL_SUCCESS: close(); break;
				default: Util.show_info_dialog("Could not install new codec.", Gradio.App.window); break;
			}
		}

		private void close(){
			message("Successfully installed new codec.");
			Util.show_info_dialog("Installed new codec successfully. Gradio must be restarted.", Gradio.App.window);
		}

	}
}
