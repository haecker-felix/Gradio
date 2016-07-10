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

			ChannelNameLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelNameLabel.set_max_width_chars(22);

			ChannelLocationLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelLocationLabel.set_max_width_chars(22);

			ChannelTagsLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelTagsLabel.set_max_width_chars(22);

			string css = """
			* {
				padding: 0;
				box-shadow: inset 0 1px @theme_base_color, 0 1px 1px alpha(black,0.4);
				border: 1px solid mix(@theme_base_color,@theme_fg_color,0.3);
				background-image: none;
				background-color: mix(@theme_base_color,@theme_bg_color,0.3);
			}
			""";

			Gtk.CssProvider provider = new Gtk.CssProvider();
			provider.load_from_data(css, css.length);
			this.get_style_context().add_provider(provider, 1);

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

