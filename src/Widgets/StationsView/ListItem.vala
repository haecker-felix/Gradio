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

        		if(station.Broken){
				string css_broken = """
					* {
						background-color: mix(@theme_base_color,#DC143C,0.5);
					}
					""";

				Gtk.CssProvider provider_broken = new Gtk.CssProvider();
				provider_broken.load_from_data(css_broken, css_broken.length);
				this.get_style_context().add_provider(provider_broken, 1);
			}
		}

	}
}

