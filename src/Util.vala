using Gtk;

public class Util{
	public static string encode_url(string s){
		var sb = new StringBuilder();
		for (var i = 0; i < s.length; i++) {
			var c = s[i];
			if (('0' <= c && c <= '9')
			 || ('A' <= c && c <= 'Z')
			 || ('a' <= c && c <= 'z')
			 || (c == '-' || c == '_' || c == '.' || c == '~')) {
				sb.append_c(c);
			} else {
				sb.append("%%%02X".printf((uint8)c));
			}
		}
		return sb.str;
	}

	public static string get_string_from_uri (string url){
		if(url != ""){
			var session = new Soup.Session ();
			session.user_agent = "gradio/"+Constants.VERSION;
			var message = new Soup.Message ("GET", url);

			session.send_message (message);
			session.abort();

			if((string)message.response_body.data != null)
				return (string)message.response_body.data;
		}
		return "";
	}

	public static async Gdk.Pixbuf get_image_from_url (string url, int height, int width){
		SourceFunc callback = get_image_from_url.callback;
		Gdk.Pixbuf output = null;

		ThreadFunc<void*> run = () => {
			if(url != ""){
				var session = new Soup.Session ();
				var message = new Soup.Message ("GET", url);
				var loader = new Gdk.PixbufLoader();

				session.user_agent = "gradio/"+Constants.VERSION;
				if(message == null){
					try{
						loader.close();
					}catch(GLib.Error e){
						warning(e.message);
					}

					return null;
				}
				session.send_message (message);

				try{
					if(message.response_body.data != null)
						loader.write(message.response_body.data);

					loader.close();
					var pixbuf = loader.get_pixbuf();
					output = pixbuf.scale_simple(width, height, Gdk.InterpType.BILINEAR);
				}catch (Error e){
					warning("Pixbufloader: " + e.message);
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
	}

	public static void remove_all_items_from_list_box (Gtk.ListBox container) {
		container.foreach(remove_all_cb);
	}

	public static void remove_all_items_from_flow_box (Gtk.FlowBox container) {
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
            		// Resolve hostname to IP address
            		var resolver = Resolver.get_default ();
            		var addresses = resolver.lookup_by_name (host, null);
            		var address = addresses.nth_data (0);
            		if (address == null) {
                		return false;
            		}
        	} catch (Error e) {
            		debug ("%s\n", e.message);
            		return false;
        	}
        	return true;
	}

	public static void open_website(string address){
		try{
			Gtk.show_uri(null, address, 0);
		}catch(Error e){
			error("Cannot open website. " + e.message);
		}

	}

	public static void add_stylesheet (string path) {
            var css_file = Constants.PKG_DATADIR + "/" + path;
            var provider = new CssProvider ();
            try {
                provider.load_from_path (css_file);
                StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
                message ("Loaded %s", css_file);
            } catch (Error e) {
                error ("Error with stylesheet: %s", e.message);
            }
}
}
