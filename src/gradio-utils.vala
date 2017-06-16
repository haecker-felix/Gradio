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


using Gtk;

namespace Gradio{
	public enum WindowMode {
		LIBRARY,
		SEARCH,
		DETAILS,
		SETTINGS,
		COLLECTION_ITEMS,
		ADD,
		COLLECTIONS
	}

	public class BackEntry{
		public WindowMode mode;
		public DataWrapper data;
	}

	// one class, but can contain different types. Used in MainWindow class for change_mode
	public class DataWrapper{
		public RadioStation station {get;set;}
		public string title {get;set;}
		public string address {get;set;}
		public Collection collection {get;set;}
	}


	public class Util{

		public static async string get_string_from_uri (string url){
			if(url != ""){
				var session = new Soup.SessionAsync ();
				session.user_agent = "gradio/"+ Config.VERSION;
				var message = new Soup.Message ("GET", url);

				session.queue_message (message, (session, msg) => {
		        		get_string_from_uri.callback ();
		    		});
				yield;

				if((string)message.response_body.data != null){
					return (string)message.response_body.data;
				}

			}
			return "";
		}

		public static void remove_all_items_from_list_box (Gtk.ListBox container) {
			container.foreach(remove_all_cb);
		}

		public static void remove_all_items_from_flow_box (Gtk.FlowBox container) {
			container.foreach(remove_all_cb);
		}

		public static void remove_all_items_from_box (Gtk.Box container) {
			container.foreach(remove_all_cb);
		}

		private static void remove_all_cb(Gtk.Widget w){
			w.destroy();
		}

		public static void show_info_dialog(string text, Gtk.Window parent){
			Gtk.MessageDialog msg = new Gtk.MessageDialog (parent, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.OK, text);
				msg.response.connect ((response_id) => {
				msg.destroy();
			});
			msg.show ();
		}

		public static string optimize_string(string str){
			string s = str;

			while(s.get_char(s.length -1) == ' '){
				s = s.substring(0, s.length-1);
			}

			return s;
		}

		public static bool check_database_connection(){
			var host = "www.radio-browser.info";

			try {
				Resolver resolver = Resolver.get_default ();
				resolver.lookup_by_name (host, null);
				return true;
			} catch (Error e) {
				critical (e.message);
				return false;
			}
		}

		public static void open_website(string address){
			try{
				Gtk.show_uri(null, address, 0);
			}catch(Error e){
				error("Cannot open website. " + e.message);
			}

		}

		public static void add_stylesheet () {
			var provider = new CssProvider ();

			provider.load_from_resource ("/de/haecker-felix/gradio/de.haeckerfelix.gradio.style.css");
			StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		}

		public static void send_notification(string summary, string body, Gdk.Pixbuf? icon = null){
			var notification = new GLib.Notification (summary);
			notification.set_body (body);
			GLib.Application.get_default ().send_notification ("de.haeckerfelix.gradio", notification);
		}


		public static Gdk.Pixbuf optiscale (Gdk.Pixbuf pixbuf, int size) {
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

		public static bool is_collection_item(int id){
			if(id > 1000000)
				return true;
			return false;
		}

		public static Cairo.Surface create_station_thumbnail (int base_size, Gdk.Pixbuf p){
			Cairo.Surface surface;
			Cairo.Context cr;
			Gtk.StyleContext context;
			Gtk.WidgetPath path;
			Gdk.Pixbuf pix = p;

			context = new Gtk.StyleContext();
			context.add_class("documents-collection-icon");

			path = new Gtk.WidgetPath ();
			Type type = typeof (Gtk.IconView);
			path.append_type (type);
		  	context.set_path (path);

			surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, base_size, base_size);
			cr = new Cairo.Context (surface);

			/* Render the thumbnail itself */
			context.render_background (cr, 0, 0, base_size, base_size);
			context.render_frame (cr, 0, 0, base_size, base_size);

			/* Now, render the tiles inside */
			context.remove_class ("documents-collection-icon");
			context.add_class ("documents-collection-icon-tile");

			pix = optiscale(pix,base_size-4);

			int pix_width = pix.get_width ();
			int pix_height = pix.get_height ();

			cr.save();

			int x = base_size - pix_width - ((base_size-pix_width)/2);
			int y = base_size - pix_height- ((base_size-pix_height)/2);

			if(x < 0) x=0;
			if(y < 0) y=0;

			cr.translate (x, y);
			cr.rectangle (0, 0, pix_width, pix_height);
			cr.clip ();

			Gdk.cairo_set_source_pixbuf (cr, pix, 0, 0);
			cr.paint ();
			cr.restore ();

			return surface;
		}

		public static Cairo.Surface create_collection_thumbnail (int base_size, List<Gdk.Pixbuf> pixbufs){
			Cairo.Surface surface;
			Cairo.Context cr;
			Gtk.StyleContext context;
			Gtk.WidgetPath path;
			Gtk.Border tile_border;
			int padding;
			int cur_x, cur_y;

			context = new Gtk.StyleContext();
			context.add_class("documents-collection-icon");

			path = new Gtk.WidgetPath ();
			Type type = typeof (Gtk.IconView);
			path.append_type (type);
		  	context.set_path (path);

			surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, base_size, base_size);
			cr = new Cairo.Context (surface);

			/* Render the thumbnail itself */
			context.render_background (cr, 0, 0, base_size, base_size);
			context.render_frame (cr, 0, 0, base_size, base_size);

			/* Now, render the tiles inside */
			context.remove_class ("documents-collection-icon");
			context.add_class ("documents-collection-icon-tile");

			int length = 4;

			if((int)pixbufs.length() < 4)
				length = (int) pixbufs.length();

			padding = int.max((int)Math.floor(base_size / 10), 4);
			tile_border = context.get_border (Gtk.StateFlags.NORMAL);

			cur_x = padding;
			cur_y = padding;


			for(int i = 0; i < length; i++){
				int small_base_size = (base_size - (padding*3))/2;

				Gdk.Pixbuf pix = pixbufs.nth_data(i);
				pix = optiscale(pix,small_base_size-4);

				int pix_width = pix.get_width ();
				int pix_height = pix.get_height ();

				if(i == 0){
					// draw border
					context.render_background (cr, padding, padding, small_base_size, small_base_size);
					context.render_frame (cr, padding, padding, small_base_size, small_base_size);

					cr.save();

					int x = padding + (small_base_size - pix_width - ((small_base_size-pix_width)/2));
					int y = padding + (small_base_size - pix_height- ((small_base_size-pix_height)/2));

					if(x < 0) x=0;
					if(y < 0) y=0;

					cr.translate (x, y);
					cr.rectangle (0, 0, pix_width, pix_height);
					cr.clip ();

					Gdk.cairo_set_source_pixbuf (cr, pix, 0, 0);
					cr.paint ();
					cr.restore ();
				}

				if(i == 1){
					// draw border
					context.render_background (cr, base_size - (padding+small_base_size), padding, small_base_size, small_base_size);
					context.render_frame (cr, base_size - (padding+small_base_size), padding, small_base_size, small_base_size);

					cr.save();

					int x = (base_size - padding - small_base_size) + (small_base_size - pix_width - ((small_base_size-pix_width)/2));
					int y = padding + (small_base_size - pix_height- ((small_base_size-pix_height)/2));

					if(x < 0) x=0;
					if(y < 0) y=0;

					cr.translate (x, y);
					cr.rectangle (0, 0, pix_width, pix_height);
					cr.clip ();

					Gdk.cairo_set_source_pixbuf (cr, pix, 0, 0);
					cr.paint ();
					cr.restore ();
				}

				if(i == 2){
					// draw border
					context.render_background (cr, padding, base_size - (padding+small_base_size), small_base_size, small_base_size);
					context.render_frame (cr, padding, base_size - (padding+small_base_size), small_base_size, small_base_size);

					cr.save();

					int y = (base_size - padding - small_base_size) + (small_base_size - pix_width - ((small_base_size-pix_width)/2));
					int x = padding + (small_base_size - pix_height- ((small_base_size-pix_height)/2));

					if(x < 0) x=0;
					if(y < 0) y=0;

					cr.translate (x, y);
					cr.rectangle (0, 0, pix_width, pix_height);
					cr.clip ();

					Gdk.cairo_set_source_pixbuf (cr, pix, 0, 0);
					cr.paint ();
					cr.restore ();
				}

				if(i == 3){
					// draw border
					context.render_background (cr, base_size - (padding+small_base_size), base_size - (padding+small_base_size), small_base_size, small_base_size);
					context.render_frame (cr, base_size - (padding+small_base_size), base_size - (padding+small_base_size), small_base_size, small_base_size);

					cr.save();

					int y = (base_size - padding - small_base_size) + (small_base_size - pix_width - ((small_base_size-pix_width)/2));
					int x = (base_size - padding - small_base_size) + (small_base_size - pix_width - ((small_base_size-pix_width)/2));

					if(x < 0) x=0;
					if(y < 0) y=0;

					cr.translate (x, y);
					cr.rectangle (0, 0, pix_width, pix_height);
					cr.clip ();

					Gdk.cairo_set_source_pixbuf (cr, pix, 0, 0);
					cr.paint ();
					cr.restore ();
				}

			}
			return surface;
		}
	}
}



