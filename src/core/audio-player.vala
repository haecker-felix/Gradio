/* This file is part of Gradio.
 *
 * Gradio is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Gradio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Gradio.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gst;

namespace Gradio{
	public class AudioPlayer : GLib.Object {

		private dynamic Element stream;

		public signal void connection_error(string text);
		public signal void connection_established();
		public signal void no_connection();

		public signal void tag_changed();
		public signal void radio_station_changed(RadioStation station);

		public signal void stopped();
		public signal void played();

		private CodecInstaller codec;

		public string tag_title;
		public string tag_homepage;
		public bool tag_has_crc;
		public string tag_audio_codec;
		public uint tag_nominal_bitrate;
		public uint tag_minimum_bitrate;
		public uint tag_maximum_bitrate;
		public uint tag_bitrate;
		public string tag_channel_mode;

		public RadioStation current_station;

		public AudioPlayer(){
			Gst.PbUtils.init();

			codec = new CodecInstaller();

			stream = ElementFactory.make ("playbin", "play");
			set_volume(Settings.volume_position);
		}

		private bool bus_callback (Gst.Bus bus, Gst.Message m) {
			switch (m.type) {
				case Gst.MessageType.ELEMENT:
					message("Check if codec is missing...");
				    	if(m.get_structure() != null && Gst.PbUtils.is_missing_plugin_message(m)) {
				    		connection_error("Missing Codec!");
				    		codec.install_missing_codec(m);
				    	}
				    	connection_error("Missing Codec!\n");
            				break;
				case MessageType.ERROR:
					GLib.Error err;
					string debug;

					m.parse_error (out err, out debug);
					message (err.message);

					stream.set_state (State.NULL);
					connection_error(err.message);
					stopped();
					break;
				case MessageType.EOS:
					stream.set_state (State.NULL);
					connection_error("End of stream!");
					stopped();
					break;
				case MessageType.STATE_CHANGED:
					Gst.State oldstate;
					Gst.State newstate;
					Gst.State pending;
					m.parse_state_changed (out oldstate, out newstate, out pending);

					if(newstate.to_string() == "GST_STATE_READY" || newstate.to_string() == "GST_STATE_NULL" || newstate.to_string() == "GST_STATE_PAUSED")
						no_connection();
					else
						connection_established();
					break;
				case MessageType.TAG:
					Gst.TagList tag_list = null;
					m.parse_tag(out tag_list);

					tag_list.get_string("title", out tag_title);
					tag_list.get_string("homepage", out tag_homepage);
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
			station.get_stream_address.begin(station.ID.to_string(), (obj, res) => {
		        	string address = station.get_stream_address.end(res);

		        	//check if new == old
		        	if(current_station != null && current_station.ID == station.ID){
					toggle_play_stop();
		        	}else{
		        		Settings.previous_station = station.ID;
					current_station = station;
					connect_to_stream_address(address);
					radio_station_changed(station);
		        	}
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
			played();
		}

		public void stop(){
			stream.set_state (State.NULL);
			stopped();
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

		//check if a specific station is being played
		public bool is_playing_station(RadioStation station){
			if(current_station != null && station != null && station.ID == current_station.ID)
				return true;
			else
				return false;
		}

		//check if any station is being played
		public bool is_playing(){
			if(stream.current_state == Gst.State.NULL)
				return false;
			else
				return true;
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

		public double get_volume (){
			return stream.volume;
		}
	}
}
