using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/list-item.ui")]
	public class ListItem : Gtk.ListBoxRow{

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

		public ListItem(RadioStation s){
			station = s;

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
			Gradio.App.imgprovider.get_station_logo.begin(station, 32, (obj, res) => {
		        	icon = Gradio.App.imgprovider.get_station_logo.end(res);

				if(icon != null){
					ChannelLogoImage.set_from_pixbuf(icon);
				}
        		});
		}

	}
}

