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

		RadioStation station;
		GradioApp app;

		public PlayerToolbar(ref GradioApp a){
			app = a;

			app.player.state_changed.connect (() => refresh_play_stop_button());
		}

		public void set_radio_station (RadioStation s){
			station = s;
			app.player.set_radio_station(station);

			ChannelHomepageLabel.set_text(station.Homepage);
			ChannelNameLabel.set_text(station.Title);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			app.player.toggle_play_stop();
			refresh_play_stop_button();
		}

		private void refresh_play_stop_button(){
			if(app.player.is_playing()){
				StopImage.set_visible(true);
				PlayImage.set_visible(false);
			}else{
				PlayImage.set_visible(true);
				StopImage.set_visible(false);
			}
		}
	}
}
