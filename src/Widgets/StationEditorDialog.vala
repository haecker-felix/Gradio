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
			station.DataAddress = UrlEntry.get_text();

			Gradio.App.data_provider.edit_radio_station(station);

			this.destroy();
		}

		private void load_data(){
			NameEntry.set_text(station.Title);


			App.data_provider.get_stream_address.begin(station.ID, (obj, res) => {
		        	string address = App.data_provider.get_stream_address.end(res);
				UrlEntry.set_text(address);
        		});


		}

	}
}
