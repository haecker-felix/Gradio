using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		[GtkChild]
		private Stack LibraryStack;
		[GtkChild]
		private ListBox StationsBox;

		GradioApp app;
		Library lib;

		public LibraryBox(ref GradioApp a, ref Library l){
			app = a;
			lib = l;

			lib.added_radio_station.connect(() => reload_radio_stations());
			lib.removed_radio_station.connect(() => reload_radio_stations());
		}

		private void reload_radio_stations(){
			Util.remove_all_widgets(ref StationsBox);
			
			foreach (var entry in lib.lib.entries){
				var station = entry.value;

				ListItem item = new ListItem(ref app, ref lib, station);

				StationsBox.add(item);
			}
		}		
	}
}
