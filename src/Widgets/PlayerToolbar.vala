using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/player-toolbar.ui")]
	public class PlayerToolbar : Gtk.ActionBar{

		[GtkChild]
		private Image PlayImage;
		[GtkChild]
		private Image StopImage;
		[GtkChild]
		private Label ChannelNameLabel;
		[GtkChild]
		private Label ChannelCurrentTitleLabel;
		[GtkChild]
		private Image StationLogo;
		[GtkChild]
		private Box StationLogoBox;
		[GtkChild]
		private Box MediaControlBox;
		[GtkChild]
		private Box InfoBox;
		[GtkChild]
		private Box ActionBox;
		[GtkChild]
		private Image AddImage;
		[GtkChild]
		private Image RemoveImage;
		[GtkChild]
		private Label LikesLabel;

		[GtkChild]
		private Label NominalBitrateLabel;
		[GtkChild]
		private Label MinimumBitrateLabel;
		[GtkChild]
		private Label MaximumBitrateLabel;
		[GtkChild]
		private Label BitrateLabel;
		[GtkChild]
		private Label CodecLabel;
		[GtkChild]
		private Label ChannelModeLabel;
		[GtkChild]
		private VolumeButton VolumeButton;

		RadioStation station;

		public PlayerToolbar(){
			this.pack_start(MediaControlBox);
			this.pack_start(StationLogoBox);
			this.pack_start(InfoBox);
			this.pack_end(ActionBox);

			App.player.state_changed.connect (() => refresh_play_stop_button());
			App.player.tag_changed.connect (() => set_information());
			App.player.radio_station_changed.connect((t) => new_station(t));
			VolumeButton.set_value(App.settings.get_double ("volume-position"));
		}

		private void send_notification(string summary, string body){
			Util.send_notification(summary, body);
		}

		private void new_station (RadioStation s){
			station = s;

			ChannelNameLabel.set_text(station.Title);
			ChannelCurrentTitleLabel.set_text("");

			StationLogo.set_from_icon_name("application-rss+xml-symbolic", IconSize.DND);
			Gdk.Pixbuf icon = null;

			Gradio.App.imgprovider.get_station_logo.begin(station, 41, (obj, res) => {
		        	icon = Gradio.App.imgprovider.get_station_logo.end(res);

				if(icon != null){
					StationLogo.set_from_pixbuf(icon);
				}else{
					StationLogo.set_from_icon_name("application-rss+xml-symbolic", IconSize.DND);		
				}
        		});

			refresh_add_remove_button();
			refresh_like_button();
			refresh_play_stop_button();

			this.set_visible(true);
		}

		[GtkCallback]
        	private void PlayStopButton_clicked (Button button) {
			App.player.toggle_play_stop();
			refresh_play_stop_button();
		}

		[GtkCallback]
        	private void VolumeButton_value_changed (double value) {
			App.player.set_volume(value);
			App.settings.set_double("volume-position", value);
		}

		[GtkCallback]
		private void AddRemoveButton_clicked(Button button){
			if(App.library.contains_station(int.parse(station.ID)))
				App.library.remove_radio_station_by_id(int.parse(station.ID));
			else
				App.library.add_radio_station_by_id(int.parse(station.ID));

			refresh_add_remove_button();
		}

		[GtkCallback]
		private void LikeButton_clicked(Button button){
			station.vote();
			refresh_like_button();
		}

		[GtkCallback]
		private void OpenHomepageButton_clicked (Button button) {
			Util.open_website(station.Homepage);
		}

		private void set_information(){
			ChannelCurrentTitleLabel.set_text(App.player.tag_title);
			NominalBitrateLabel.set_text(App.player.tag_nominal_bitrate.to_string() + " kBit/s");
			MinimumBitrateLabel.set_text(App.player.tag_minimum_bitrate.to_string() + " kBit/s");
			MaximumBitrateLabel.set_text(App.player.tag_maximum_bitrate.to_string() + " kBit/s");
			BitrateLabel.set_text(App.player.tag_bitrate.to_string()  + " kBit/s");
			CodecLabel.set_text(App.player.tag_audio_codec);
			ChannelModeLabel.set_text(App.player.tag_channel_mode);

			if (App.settings.get_boolean ("show-notifications"))
				if(App.player.tag_title != null)
					send_notification(station.Title, App.player.tag_title);
		}

		private void refresh_like_button(){
			LikesLabel.set_text(station.Votes.to_string());
		}

		private void refresh_add_remove_button(){
			if(Gradio.App.library.contains_station(int.parse(station.ID))){
				AddImage.set_visible(false);
				RemoveImage.set_visible(true);
			}else{
				AddImage.set_visible(true);
				RemoveImage.set_visible(false);
			}
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
