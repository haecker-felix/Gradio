using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/library-box.ui")]
	public class LibraryBox : Gtk.Box{

		[GtkChild]
		private Box ContentBox;

		private StationsView library_view;

		public LibraryBox(){
			library_view = new StationsView("Library", true);
			library_view.set_stations_from_hash_table(App.library.lib);

			ContentBox.add(library_view);

			App.library.added_radio_station.connect(() => library_view.reload_view());
			App.library.removed_radio_station.connect(() => library_view.reload_view());

			ContentBox.show_all();
		}

		public void show_grid_view(){
			library_view.show_grid_view();
		}

		public void show_list_view(){
			library_view.show_list_view();
		}
	}
}
