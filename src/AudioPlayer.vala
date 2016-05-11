using Gst;

public class AudioPlayer {

	dynamic Element stream;

	public signal void connection_error(string text);
	public signal void state_changed();

	private bool bus_callback (Gst.Bus bus, Gst.Message message) {
		switch (message.type) {
			case MessageType.ERROR:
				GLib.Error err;
				string debug;
				message.parse_error (out err, out debug);
				stdout.printf ("Error: %s\n", err.message);
				connection_error(err.message);
				break;
			case MessageType.EOS:
				stdout.printf ("Info: End of stream.\n");
				break;
			case MessageType.STATE_CHANGED:
				Gst.State oldstate;
				Gst.State newstate;
				Gst.State pending;
				message.parse_state_changed (out oldstate, out newstate, out pending);
				stdout.printf ("Info: State changed: %s->%s:%s\n", oldstate.to_string (), newstate.to_string (), pending.to_string ());
				state_changed();
				break;
			default:
				break;
		}
		return true;
	}

	public void set_radio_station(RadioStation station){
		connect_to_stream_address(station.Source);
	}

	private void connect_to_stream_address(string address){
		stop();

		stream = ElementFactory.make ("playbin", "play");
		stream.uri = address;

		Gst.Bus bus = stream.get_bus ();
		bus.add_watch (1, bus_callback);

		play();
	}

	public void play () {
		stream.set_state (State.PLAYING);
	}

	public void stop(){
		stream.set_state (State.NULL);
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
}

