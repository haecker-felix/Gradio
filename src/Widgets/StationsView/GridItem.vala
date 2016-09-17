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
		private Label LikesLabel;
		[GtkChild]
		private Image ChannelLogoImage;
		[GtkChild]
		private Image InLibraryImage;
		[GtkChild]
		private Image NotInLibraryImage;

		public RadioStation station;

		public GridItem(RadioStation s){
			station = s;

			ChannelNameLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelNameLabel.set_max_width_chars(25);
			ChannelLocationLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelLocationLabel.set_max_width_chars(25);
			ChannelTagsLabel.set_ellipsize(Pango.EllipsizeMode.END);
			ChannelTagsLabel.set_max_width_chars(25);

			load_information();
		}

		private void load_information(){
			ChannelNameLabel.set_text(station.Title);
			ChannelLocationLabel.set_text(station.Country + " " + station.State);
			ChannelTagsLabel.set_text(station.Tags);
			LikesLabel.set_text(station.Votes.to_string());

			if(Gradio.App.library.contains_station(int.parse(station.ID))){
				NotInLibraryImage.set_visible(false);
				InLibraryImage.set_visible(true);
			}else{
				NotInLibraryImage.set_visible(true);
				InLibraryImage.set_visible(false);
			}

			Gdk.Pixbuf icon = null;
			Gradio.App.imgprovider.get_station_logo.begin(station, 64, (obj, res) => {
		        	icon = Gradio.App.imgprovider.get_station_logo.end(res);

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);
				}
        		});
		}

		[GtkCallback]
		private void GradioGridItem_clicked(Button b){
			this.activate();
		}
	}
}

