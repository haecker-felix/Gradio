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

		public ImageCache() {

		}

		public async Gdk.Pixbuf get_image(string url) {
			uint url_hash = url.hash();
		    	Gdk.Pixbuf pixbuf = null;

		    	return pixbuf;
		}
    }
}
