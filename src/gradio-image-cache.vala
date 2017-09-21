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
 *
 * Original source file: https://github.com/needle-and-thread/vocal/blob/master/src/Services/ImageCache.vala
 * Additional contributors/authors: Akshay Shekher <voldyman666@gmail.com>
 */

namespace Gradio {

	public class ImageCache : GLib.Object {

		private static Soup.Session session;

		public ImageCache() {
			session = new Soup.Session();
			session.user_agent = "gradio/"+ Config.VERSION;
		}

		public async Gdk.Pixbuf get_image(string url) {
			uint url_hash = url.hash();
		    	Gdk.Pixbuf pixbuf = null;

			if(is_image_cached(url_hash)){
			 	pixbuf = get_cached_image(url_hash);
			}else{
			 	pixbuf = yield get_image_from_url(url);

			 	if(App.settings.enable_caching)
			 		cache_image.begin(pixbuf, url_hash);
			}

		    	return pixbuf;
		}

		public async bool clear_cache(){
			try{
				File cache_location = File.new_for_path(GLib.Environment.get_user_cache_dir()+"/gradio/");
				FileEnumerator enumerator = yield
		                cache_location.enumerate_children_async("standard::*", FileQueryInfoFlags.NONE, Priority.DEFAULT, null);
		            	List<FileInfo> infos;
		            	while((infos = yield enumerator.next_files_async(10)) != null) {
		                	foreach(var info in infos) {
		                		var name = info.get_name();
		                		var file = File.new_for_path("%s/%s".printf(GLib.Environment.get_user_cache_dir()+"/gradio", name));
		                		file.delete();
		                	}
				}

				return true;
			}catch (Error e){
				critical("Could not clear icon cache: %s", e.message);
				return false;
			}

		}

		private bool is_image_cached(uint hash){
			return FileUtils.test (GLib.Environment.get_user_cache_dir()+"/gradio/"+hash.to_string()+".png", FileTest.EXISTS);
		}

		private Gdk.Pixbuf get_cached_image(uint hash){
			Gdk.Pixbuf pixbuf = null;
			try{
				pixbuf = new Gdk.Pixbuf.from_file(GLib.Environment.get_user_cache_dir()+"/gradio/"+hash.to_string()+".png");
			}catch (GLib.Error e){
				warning("Could not get cached image: %s", e.message);
			}

			return pixbuf;
		}

		private async void cache_image(Gdk.Pixbuf pixbuf, uint hash){
			var file_location = "%s/%u.png".printf(GLib.Environment.get_user_cache_dir()+"/gradio/", hash);
                	var cfile = File.new_for_path(file_location);
			FileIOStream fiostream = null;

			File dir = File.new_for_path (GLib.Environment.get_user_cache_dir()+"/gradio/");
			if(!dir.query_exists()){
				try{
					dir.make_directory_with_parents();
				}catch (Error e){
					critical("Could not create new cache directory: " + e.message);
				}

				message("Created a cache folder.");
			}

			try{
		        	if (cfile.query_exists()) {
		            		fiostream = yield cfile.replace_readwrite_async(null, false, FileCreateFlags.NONE);
		        	} else {
		            		fiostream = yield cfile.create_readwrite_async(FileCreateFlags.NONE);
		        	}
			   	pixbuf.save_to_stream(fiostream.get_output_stream(), "png");
			}catch (Error e){
				warning("Could not cache image: %s", e.message);
			}
		}

		private async Gdk.Pixbuf get_image_from_url(string url){
			Gdk.Pixbuf pixbuf = null;
        		InputStream image_stream = null;
            		Soup.Request req = null;

			try{
				req = session.request(url);
		    		image_stream = yield req.send_async(null);
		    		pixbuf = yield new Gdk.Pixbuf.from_stream_async(image_stream, null);
			}catch (Error e){
				warning("Could not load image for \"%s\" (%s)", url, e.message);
				pixbuf = new Gdk.Pixbuf.from_resource("/de/haecker-felix/gradio/icons/hicolor/48x48/apps/de.haeckerfelix.gradio.png");
			}

			return pixbuf;
		}
    }

}
