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

	public class Thumbnail{

		private List<Gdk.Pixbuf> _pixbufs;
		private Cairo.Surface _surface;
		private Cairo.Context cr;
		private Gtk.StyleContext context;
		private Gtk.WidgetPath path;

		private int base_size;
		private RadioStation station;
		private Collection collection;

		public signal void updated();

		public Cairo.Surface surface{
			get{return _surface;}
		}

		private bool is_collection_thumbnail = false;

		public Thumbnail.for_station (int bs, RadioStation s){
			base_size = bs;
			station = s;
			setup();

			App.image_cache.get_image.begin(station.icon_address, (obj, res) => {
			     	Gdk.Pixbuf pixbuf = App.image_cache.get_image.end(res);
		             	if (pixbuf != null) {
		             		_pixbufs.insert(pixbuf, 0);
			 		render_icon(0, 0, base_size, 0);
		             	}
			});
		}

		public Thumbnail.for_collection (int bs, Collection c){
			is_collection_thumbnail = true;

			base_size = bs;
			collection = c;
			setup();

			// collection station model has changed
			collection.station_model.items_changed.connect((position, removed, added) => {
				if(removed == 0 && added == 1){
					RadioStation station = (RadioStation)collection.station_model.get_item(position);
					App.image_cache.get_image.begin(station.icon_address, (obj, res) => {
					    	Gdk.Pixbuf pixbuf = App.image_cache.get_image.end(res);
						_pixbufs.insert(pixbuf, (int)position);
						render_collection_thumbnail();
					});
				}
				if(removed == 1 && added == 0){
					Gdk.Pixbuf pixbuf = _pixbufs.nth_data(position);
					_pixbufs.remove(pixbuf);
					render_collection_thumbnail();
				}
			});

		}

		public void set_zoom(int zoom){
			base_size = zoom;

			_surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, base_size, base_size);
			cr = new Cairo.Context (_surface);
			render_border(0, 0, base_size, base_size);

			if(is_collection_thumbnail){
				message("update collection thumbnail zoom");
				render_collection_thumbnail();
			}else{
			 	render_icon(0, 0, base_size, 0);
			}
		}

		public void show_empty_box(){
			cr.set_source_rgba(0,0,0,0);
			cr.paint();
			render_border(0, 0, base_size, base_size);

			updated();
		}

		// do basic work, which is the same for the station and collection thumbnail
		private void setup(){
			_pixbufs = new List<Gdk.Pixbuf>();

			context = new Gtk.StyleContext();
			context.add_class("thumbnail");

			path = new Gtk.WidgetPath ();
			Type type = typeof (Gtk.IconView);
			path.append_type (type);
		  	context.set_path (path);

			_surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, base_size, base_size);
			cr = new Cairo.Context (_surface);
		}

		private void render_collection_thumbnail(){
			show_empty_box();

			int padding = int.max((int)Math.floor(base_size / 10), 4);
			int icon_size = base_size/3;

			_pixbufs.foreach((pixbuf) => {
				// add it to the correct place
				switch(_pixbufs.index(pixbuf)){
					case 0: render_icon(padding, padding, icon_size, _pixbufs.index(pixbuf)); break;
					case 1: render_icon(base_size-padding-icon_size, padding, icon_size, _pixbufs.index(pixbuf)); break;
					case 2: render_icon(padding, base_size-padding-icon_size, icon_size, _pixbufs.index(pixbuf)); break;
					case 3: render_icon(base_size-padding-icon_size, base_size-padding-icon_size, icon_size, _pixbufs.index(pixbuf)); break;
				}
			});
		}

		private void render_border (int start_x, int start_y, int width, int height){
			context.render_background (cr, start_x, start_y, width, height);
			context.render_frame (cr, start_x, start_y, width, height);
			context.remove_class ("thumbnail");
			context.add_class ("thumbnail");
		}

		private void render_icon (int box_x, int box_y, int box_size, int pix_id){
			render_border(box_x, box_y, box_size, box_size);

			Gdk.Pixbuf pixbuf = _pixbufs.nth_data(pix_id);
			if(pixbuf != null){
				pixbuf = optiscale(pixbuf,box_size-4);

				int width = pixbuf.get_width ();
				int height = pixbuf.get_height ();
				int x = box_x + (box_size - width - ((box_size-width)/2));
				int y = box_y + (box_size - height - ((box_size-height)/2));

				if(x < 0) x=0;
				if(y < 0) y=0;

				cr.save();

				cr.translate (x, y);
				cr.rectangle (0, 0, width, height);
				cr.clip ();

				Gdk.cairo_set_source_pixbuf (cr, pixbuf, 0, 0);
				cr.paint ();
				cr.restore ();

				updated();
			}
		}

		private Gdk.Pixbuf optiscale (Gdk.Pixbuf pixbuf, int size) {
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

				return pixbuf.scale_simple ((int)sc_w, (int)sc_h, Gdk.InterpType.BILINEAR);
			}

			return pixbuf;
		}

	}
}
