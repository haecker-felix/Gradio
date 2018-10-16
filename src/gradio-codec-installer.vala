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

using Gst.PbUtils;

namespace Gradio{

	public class CodecInstaller{

		public CodecInstaller(){
			init();
		}

		public void install_missing_codec(Gst.Message m){
			string description = Gst.PbUtils.missing_plugin_message_get_description (m);
			string missingcodec = Gst.PbUtils.missing_plugin_message_get_installer_detail(m);
			string[] installer_detail = {Gst.PbUtils.missing_plugin_message_get_installer_detail (m)};

			message("Try to install %s", description);

			if(Gst.PbUtils.install_plugins_supported()){
				var context = new Gst.PbUtils.InstallPluginsContext();
				Gst.PbUtils.install_plugins_async(installer_detail, context, install_callback);
			}else{
				warning("Installation failed. Codec installation is not supported by your flatpak's distribution. Please install the missin codec by yourself.");
				App.window.show_notification("Automatic codec installation isn't supported by your flatpak's distribution.\nPlease install \""+missingcodec+"\" manually.");
			}
		}

		private void install_callback(Gst.PbUtils.InstallPluginsReturn result){
			message("resulted");
			switch(result){
				case Gst.PbUtils.InstallPluginsReturn.SUCCESS: close(); break;
				case Gst.PbUtils.InstallPluginsReturn.PARTIAL_SUCCESS: close(); break;
				default: App.window.show_notification("Could not install new codec."); break;
			}
		}

		private void close(){
			message("Successfully installed new codec.");
		}

	}
}
