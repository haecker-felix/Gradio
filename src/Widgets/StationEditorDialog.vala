using Gtk;
namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/station-editor-dialog.ui")]
	public class StationEditorDialog : Gtk.Dialog {

		[GtkChild]
		private Entry NameEntry;
		[GtkChild]
		private Entry UrlEntry;

		private RadioStation station;

		public StationEditorDialog (RadioStation s) {
			station = s;

			load_data();
		}

		[GtkCallback]
        	private void ApplyButton_clicked (Button button) {

			station.Title = NameEntry.get_text();

			this.destroy();
		}

		private void load_data(){
			NameEntry.set_text(station.Title);


		}

	}
}
