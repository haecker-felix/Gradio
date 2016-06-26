using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/grid-item.ui")]
	public class GridItem : Gtk.FlowBoxChild{

		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelLocationLabel;
		[GtkChild]
		private Label ChannelTagsLabel;
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
			ChannelLocationLabel.set_text(station.Country + " " + station.State);
			ChannelTagsLabel.set_text(station.Tags);

			Gdk.Pixbuf icon = null;
			Util.get_image_from_url.begin(station.Icon, 64, 64, (obj, res) => {
		        	icon = Util.get_image_from_url.end(res);

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);	
				}
        		});
		}
	}
}

