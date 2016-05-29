using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/grid-item.ui")]
	public class GridItem : Gtk.FlowBoxChild{

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Image ChannelLogoImage;

		public RadioStation station;

		public GridItem(RadioStation s){
			station = s;

			load_information();
			station.data_changed.connect(() => load_information());
		}

		private void load_information(){
			ChannelNameLabel.set_text(station.Title);

			Gdk.Pixbuf icon = null;
			Util.get_image_from_url(station.Icon, 60, 60, (obj, res) => {
		    		try {
		        		icon = Util.get_image_from_url.end(res);
		    		} catch (ThreadError e) {
		        		stderr.printf("Error: Thread:" + e.message + "\n");
		    		}

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);	
				}
        		});
		}
	}
}

