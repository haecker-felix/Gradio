using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		[GtkChild]
		private Stack LibraryStack;
		[GtkChild]
		private ListBox StationsBox;

		public LibraryBox(){
			App.library.added_radio_station.connect(() => reload_radio_stations());
			App.library.removed_radio_station.connect(() => reload_radio_stations());

			reload_radio_stations();
		}

		private void reload_radio_stations(){
			Util.remove_all_widgets(ref StationsBox);
			
			if(App.library.lib.size != 0){
				foreach (var entry in App.library.lib.entries){
					var station = entry.value;

					ListItem item = new ListItem(station);

					StationsBox.add(item);
				}
				LibraryStack.set_visible_child_name("library");
			}else{
				LibraryStack.set_visible_child_name("empty_library");
			}

		}		
	}
}
