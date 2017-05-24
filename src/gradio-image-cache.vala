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
		private class CacheState {
            	public signal void load_complete();
            	public bool is_loaded;
        }

        private static DiskCacher cacher;
        private static HashTable<uint, File> cache;
        private static Soup.Session soup_session;
        private static CacheState state;

        static construct {
            	// till the cache get initialized
            	state = new CacheState();
            	state.is_loaded = false;
		cache = new HashTable<uint, File>(direct_hash, direct_equal);

            	var home_dir = GLib.Environment.get_home_dir();
            	var cache_directory = Environment.get_user_cache_dir() + "/gradio";

            	soup_session = new Soup.Session();
            	soup_session.user_agent = "gradio/"+ Config.VERSION;
            	cacher = new DiskCacher(cache_directory);
            	cacher.get_cached_files.begin((obj, res) => {
            		cache = cacher.get_cached_files.end(res);
                	state.is_loaded = true;
                	state.load_complete();
            	});
        }

        public ImageCache() { }

        // Get image and cache it
        public async Gdk.Pixbuf get_image(string url) {
		uint url_hash = url.hash();
            	Gdk.Pixbuf pixbuf;

             	if (!state.is_loaded) {
             		state.load_complete.connect(() => { get_image.callback(); });
                 	yield;
             	}

             	if (cache.contains(url_hash) && cache.@get(url_hash) != null) {
                 	pixbuf = yield cacher.get_cached_file(cache.@get(url_hash));
                 	if (pixbuf == null) {
                     		warning("Could not load cached file");
                 	}
             	} else {
                 	pixbuf = yield load_image_async(url);
                 	if (pixbuf != null) {
                     		var cached_file = yield cacher.cache_file(url_hash, pixbuf);
                     		cache.@set(url_hash, cached_file);
                 	}
             	}

		Util.remove_transparency(ref pixbuf);

            	return pixbuf;
        }

        private async Gdk.Pixbuf load_image_async(string url) {
        	Gdk.Pixbuf pixbuf = null;
        	InputStream image_stream = null;
            	Soup.Request req = null;

		// That's not the best way to catch errors, but i think it is enough for this case ;)
		try { req = soup_session.request(url); }catch(Error e){}
            	try { image_stream = yield req.send_async(null); }catch(Error e){}
            	try{ pixbuf = yield new Gdk.Pixbuf.from_stream_async(image_stream, null); }catch(Error e){}

		if(pixbuf == null) pixbuf = new Gdk.Pixbuf.from_resource("/de/haecker-felix/gradio/icons/hicolor/48x48/apps/de.haeckerfelix.gradio.png");

            	return pixbuf;
        }

        private class DiskCacher {
            	private File cache_location;
            	private string location;

            	public DiskCacher(string location) {
                	this.location = location;
                	this.cache_location = File.new_for_path(location);
            	}

            	public async HashTable<uint, File> get_cached_files() {
                	HashTable<uint, File> files = new HashTable<uint, File>(direct_hash, direct_equal);

                	if (!cache_location.query_exists()) {
                    		cache_location.make_directory_with_parents();
                	}

                	try {
                    		FileEnumerator enumerator = yield
                        	cache_location.enumerate_children_async("standard::*", FileQueryInfoFlags.NONE, Priority.DEFAULT, null);
                    		List<FileInfo> infos;
                    		while((infos = yield enumerator.next_files_async(10)) != null) {
                        		foreach(var info in infos) {
                            			var name = info.get_name();
                            			var file = File.new_for_path("%s/%s".printf(location, name));
                            			var hashed_name = (uint)uint64.parse(name);
                            			files.@set(hashed_name, file);
                        		}
                    		}
                	} catch (Error e) {
                    		warning("Could not load cached images " + e.message);
                	}
                	return files;
            	}

            	public async File cache_file(uint hashed_name, Gdk.Pixbuf pixbuf) {
                	var file_loc = "%s/%ud.png".printf(this.location, hashed_name);
                	var cfile = File.new_for_path(file_loc);
			FileIOStream fiostream = null;

			try{
		        	if (cfile.query_exists()) {
		            		fiostream = yield cfile.replace_readwrite_async(null, false, FileCreateFlags.NONE);
		        	} else {
		            		fiostream = yield cfile.create_readwrite_async(FileCreateFlags.NONE);
		        	}
			}catch (Error e){}

                	// switch to async version later, currently the bindings have a bug
                	pixbuf.save_to_stream(fiostream.get_output_stream(), "png");

                	return cfile;
            	}

            	public async Gdk.Pixbuf get_cached_file(File file) {
                	Gdk.Pixbuf pixbuf = null;
                	try {
                    		var fiostream = yield file.open_readwrite_async();
                    		pixbuf = yield new Gdk.Pixbuf.from_stream_async(fiostream.get_input_stream(), null);
                	} catch(Error e) {
                    		warning ("Couldn't write to file. " + e.message);
                	}

                	return pixbuf;
            	}
	}
    }
}
