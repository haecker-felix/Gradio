using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		[GtkChild]
		private Box ContentBox;

		private StationsGridView list_view_library;

		public LibraryBox(){
			list_view_library = new StationsGridView();
			list_view_library.set_stations(ref App.library.lib);

			ContentBox.add(list_view_library);

			App.library.added_radio_station.connect(() => list_view_library.reload_view());
			App.library.removed_radio_station.connect(() => list_view_library.reload_view());


			ContentBox.show_all();
			//reload_radio_stations();
		}	
	}
}
