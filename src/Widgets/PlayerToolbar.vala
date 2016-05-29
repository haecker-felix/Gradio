using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/player-toolbar.ui")]
	public class PlayerToolbar : Gtk.Box{

		[GtkChild]
		private Image PlayImage;
		[GtkChild]
		private Image StopImage;
		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelHomepageLabel;
		[GtkChild]
		private Image StationLogo;

		RadioStation station;

		public PlayerToolbar(){
			App.player.state_changed.connect (() => refresh_play_stop_button());
		}

		public void set_radio_station (RadioStation s){
			station = s;

			ChannelHomepageLabel.set_text(station.Homepage);
			ChannelNameLabel.set_text(station.Title);

			Gdk.Pixbuf icon = null;
			Util.get_image_from_url(station.Icon, 40, 40, (obj, res) => {
		    		try {
		        		icon = Util.get_image_from_url.end(res);
		    		} catch (ThreadError e) {
		        		stderr.printf("Error: Thread:" + e.message + "\n");
		    		}

				if(icon != null){
					StationLogo.set_from_pixbuf(icon);
				}else{
					StationLogo.set_from_icon_name("application-rss+xml-symbolic", IconSize.DND);		
				}
				
        		});
			
			this.set_visible(true);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
			refresh_play_stop_button();
		}

		private void refresh_play_stop_button(){
			if(App.player.is_playing()){
				StopImage.set_visible(true);
				PlayImage.set_visible(false);
			}else{
				PlayImage.set_visible(true);
				StopImage.set_visible(false);
			}
		}
	}
}
