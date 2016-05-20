using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		GradioApp app;

		public LibraryBox(ref GradioApp a){
			app = a;
		}		
	}
}
