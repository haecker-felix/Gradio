using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/stations-view-button.ui")]
	public class StationsViewButton : Gtk.Box{

		public signal void clicked();

		public StationsViewButton(){

		}

		[GtkCallback]
		private void click (Button button){
			clicked();
		}

	}
}

