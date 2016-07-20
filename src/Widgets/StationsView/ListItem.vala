using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/list-item.ui")]
	public class ListItem : Gtk.ListBoxRow{

		[GtkChild]
		private Image ChannelLogoImage;
		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label LocationLabel;

		public RadioStation station;

		public ListItem(RadioStation s){
			station = s;

			ChannelNameLabel.set_text(station.Title);
			LocationLabel.set_text(station.Country + " " + station.State);

			Gdk.Pixbuf icon = null;
			Util.get_image_from_url.begin(station.Icon, 32, 32, (obj, res) => {
		        	icon = Util.get_image_from_url.end(res);

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);	
				}
        		});
		}

	}
}

