using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		[GtkChild]
		private Box ContentBox;

		private StationsListView list_view_library;
		private StationsGridView grid_view_library;

		public LibraryBox(){
			list_view_library = new StationsListView();
			list_view_library.set_stations(ref App.library.lib);

			grid_view_library = new StationsGridView();
			grid_view_library.set_stations(ref App.library.lib);

			ContentBox.add(grid_view_library);

			App.library.added_radio_station.connect(() => list_view_library.reload_view());
			App.library.removed_radio_station.connect(() => list_view_library.reload_view());
			App.library.added_radio_station.connect(() => grid_view_library.reload_view());
			App.library.removed_radio_station.connect(() => grid_view_library.reload_view());

			ContentBox.show_all();
		}	

		public void show_grid_view(){
			ContentBox.remove(list_view_library);
			ContentBox.add(grid_view_library);
			ContentBox.show_all();
		}

		public void show_list_view(){
			ContentBox.remove(grid_view_library);
			ContentBox.add(list_view_library);
			ContentBox.show_all();
		}
	}
}
