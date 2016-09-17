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

	public class ImageProvider{

		public ImageProvider(){

		}

		public async Gdk.Pixbuf? get_station_logo (RadioStation station, int size){
			if(Gradio.App.settings.get_boolean ("load-pictures")){
				SourceFunc callback = get_station_logo.callback;
				Gdk.Pixbuf output = null;

				ThreadFunc<void*> run = () => {
					if(station.Icon != ""){
						var session = new Soup.Session ();
						var message = new Soup.Message ("GET", station.Icon);
						var loader = new Gdk.PixbufLoader();

						if(message == null){
							try{
								loader.close();
							}catch(GLib.Error e){
								warning(e.message);
							}
							return null;
						}

						session.user_agent = "gradio/"+Constants.VERSION;
						session.send_message (message);

						try{
							if(message.response_body.data != null)
								loader.write(message.response_body.data);

							loader.close();
							var pixbuf = loader.get_pixbuf();

							optiscale(ref pixbuf, size);
							output = pixbuf;
						}catch (Error e){
							debug("Pixbufloader: " + e.message);
						}

						session.abort();
					}

					Idle.add((owned) callback);
					Thread.exit (1.to_pointer ());
					return null;
				};

				new Thread<void*> ("image_thread", run);
				yield;
				return output;
			}else{
				return null;
			}
		}

		// returns a resized pixbuf to fit the current user's screen resolution
		private void optiscale (ref Gdk.Pixbuf pixbuf, int size) {
			double pixb_w = pixbuf.get_width();
			double pixb_h = pixbuf.get_height();

			if((pixb_w > size) || (pixb_h > size)){
				double sc_factor_w = size / pixb_w;
				double sc_factor_h = size / pixb_h;

				double sc_factor = 0;

				if(sc_factor_w >= sc_factor_h)
					sc_factor = sc_factor_h;
				if(sc_factor_h >= sc_factor_w)
					sc_factor = sc_factor_w;

				double sc_w = pixb_w * sc_factor;
				double sc_h = pixb_h * sc_factor;

				pixbuf = pixbuf.scale_simple ((int)sc_w, (int)sc_h, Gdk.InterpType.BILINEAR);
			}
		}
	}
}
