using Gst;

namespace Gradio{
	public class AudioPlayer : GLib.Object {

		private dynamic Element stream;

		public signal void radio_station_changed(RadioStation station);
		public signal void connection_error(string text);
		public signal void state_changed();
		public signal void tag_changed();

		public string tag_title;
		public bool tag_has_crc;
		public string tag_audio_codec;
		public uint tag_nominal_bitrate;
		public uint tag_minimum_bitrate;
		public uint tag_maximum_bitrate;
		public uint tag_bitrate;
		public string tag_channel_mode;

		public RadioStation current_station;

		public AudioPlayer(){
			stream = ElementFactory.make ("playbin", "play");
			set_volume(1.0);

			this.notify.connect ((s, p) => stdout.printf ("Property %s changed\n", p.name));
		}

		private bool bus_callback (Gst.Bus bus, Gst.Message m) {
			switch (m.type) {
				case MessageType.ERROR:
					GLib.Error err;
					string debug;

					m.parse_error (out err, out debug);
					print (err.message);

					stream.set_state (State.NULL);
					connection_error(err.message);
					state_changed();
					break;
				case MessageType.EOS:
					print ("End of stream.");
					stream.set_state (State.NULL);

					state_changed();
					break;
				case MessageType.STATE_CHANGED:
					Gst.State oldstate;
					Gst.State newstate;
					Gst.State pending;
					m.parse_state_changed (out oldstate, out newstate, out pending);
					GLib.debug ("State changed: %s -> %s", oldstate.to_string (), newstate.to_string ());

					state_changed();				
					break;
				case MessageType.TAG:
					Gst.TagList tag_list = null;
					m.parse_tag(out tag_list);

					tag_list.get_string("title", out tag_title);

					tag_list.get_boolean("has-crc", out tag_has_crc);

					tag_list.get_string("audio-codec", out tag_audio_codec);

					tag_list.get_uint("nominal-bitrate", out tag_nominal_bitrate);
					tag_nominal_bitrate = tag_nominal_bitrate/1000;

					tag_list.get_uint("minimum-bitrate", out tag_minimum_bitrate);
					tag_minimum_bitrate = tag_minimum_bitrate/1000;

					tag_list.get_uint("maximum-bitrate", out tag_maximum_bitrate);
					tag_maximum_bitrate = tag_maximum_bitrate/1000;

					tag_list.get_uint("bitrate", out tag_bitrate);
					tag_bitrate = tag_bitrate/1000;

					tag_list.get_string("channel-mode", out tag_channel_mode);

					tag_changed();
					break;
				default:
					break;
			}
			return true;
		}

		public void set_radio_station(RadioStation station){
			App.data_provider.get_stream_address.begin(station.ID, (obj, res) => {
		        	string address = App.data_provider.get_stream_address.end(res);
				current_station = station;
				connect_to_stream_address(address);
				radio_station_changed(station);			
        		});
		}

		private void connect_to_stream_address(string address){
			stop();

			stream.uri = address;

			Gst.Bus bus = stream.get_bus ();
			bus.add_watch (1, bus_callback);

			play();
		}

		public void play () {
			stream.set_state (State.PLAYING);
			state_changed();
		}

		public void stop(){
			stream.set_state (State.NULL);
			state_changed();
		}

		public void toggle_play_stop(){
			if(stream.current_state == Gst.State.NULL){
				stream.set_state (State.PLAYING);
				play();
			}else{
				stream.set_state (State.NULL);
				stop();
			}
		}

		public bool is_playing(){
			if(stream.current_state == Gst.State.NULL){
				return false;
			}else{
				return true;
			}
		}

		public void mute_audio (){
			stream.mute = true;
		}

		public void unmute_audio(){
			stream.mute = false;
		}

		public void set_volume (double v){
			stream.volume = v;
		}
	}
}
