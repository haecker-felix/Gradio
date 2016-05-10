public class Util{
	public static string get_string_from_uri (string uri){
		File file = File.new_for_uri (uri);
		string data = "";

		try {
			FileInputStream @is = file.read ();
			DataInputStream dis = new DataInputStream (@is);
			string line;

			while ((line = dis.read_line ()) != null) {
				data = data + line;
			}
		} catch (Error e) {
			stdout.printf ("Error: %s\n", e.message);
		}

		return data;

	}

	public static void remove_all_widgets (ref Gtk.ListBox container) {
		container.foreach(remove_all_cb);
	}

	private static void remove_all_cb(Gtk.Widget w){
		w.destroy();
	}

	public static string optimize_string(string str){
		string s = str;

		if(s.get_char(s.length -1) == ' '){
			s = s.substring(0, s.length-1);
		}

		return s;
	}
}
