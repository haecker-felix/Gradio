using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/manual-box.ui")]
	public class ManualBox : Gtk.Box{

		[GtkChild]
		private Entry AddressEntry;

		GradioApp app;

		public ManualBox(ref GradioApp a){
			app = a;
		}

		[GtkCallback]
		private void ConnectButton_clicked (Button button) {
			string address = AddressEntry.text;

			RadioStation station = new RadioStation.parse_from_id(int.parse(address));
			app.set_radio_station(station);
		}

	}
}
