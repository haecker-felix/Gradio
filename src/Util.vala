public class Util{
	public static string get_string_from_uri (string url){
		if(url != ""){
			var session = new Soup.Session ();
			session.user_agent = "gradio/"+Gradio.App.version;
			var message = new Soup.Message ("GET", url);

			session.send_message (message);

			return (string)message.response_body.data;
			}
		return "";
	}

	public static async Gdk.Pixbuf get_image_from_url (string url, int height, int width){
		SourceFunc callback = get_image_from_url.callback;
		Gdk.Pixbuf output = null;

		ThreadFunc<void*> run = () => {
			if(check_connection(url)){			
				if(url != ""){	
					var session = new Soup.Session ();
					session.user_agent = "gradio/"+Gradio.App.version;
					var message = new Soup.Message ("GET", url);
					session.send_message (message);
					var loader = new Gdk.PixbufLoader();

					try{
						if(message.response_body.data != null){
							loader.write(message.response_body.data);
						}
					loader.close();
					var pixbuf = loader.get_pixbuf();
					output = pixbuf.scale_simple(width, height, Gdk.InterpType.BILINEAR);
			
					}catch (Error e){
						warning("Pixbufloader: " + e.message);
					}
				}
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
		try {
			File file = File.new_for_uri ("http://www.radio-browser.info/");
			file.read ();
			return true;
		} catch (Error e) {
			warning (e.message);
			return false;
		}
	}

	public static bool check_connection(string url){
		try {
			File file = File.new_for_uri (url);
			file.read ();
			return true;
		} catch (Error e) {
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
}
