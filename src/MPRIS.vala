namespace Gradio {

	public class MPRIS : GLib.Object {
		public MprisPlayer player = null;
		public MprisRoot root = null;

		private unowned DBusConnection conn;
		private uint owner_id;

		private RadioStation current_station;

		public void initialize(){
			owner_id = Bus.own_name(BusType.SESSION, "org.mpris.MediaPlayer2.gradio", GLib.BusNameOwnerFlags.NONE, on_bus_acquired, on_name_acquired, on_name_lost);

			if(owner_id == 0) {
				warning("Could not initialize MPRIS session.\n");
		    	}else{
				message("Successfully initialized MPRIS session.");
			}
	    	}


	  	private void on_bus_acquired(DBusConnection connection, string name) {
		    	this.conn = connection;
		    	try {
			    	root = new MprisRoot();
			    	connection.register_object("/org/mpris/MediaPlayer2", root);
			    
			    	player = new MprisPlayer(connection);
				App.player.state_changed.connect(() => {
					string status = "Stopped";
					if(App.player.is_playing())
						status = "Playing";

					player.set_playback_status(status);
				});
				App.player.tag_changed.connect(() => {
					if(current_station != null){
						player.set_metadata(current_station.ID, current_station.Icon, current_station.Title);
					}
				});
			    	connection.register_object("/org/mpris/MediaPlayer2", player);
		    	}catch(IOError e) {
			    	warning("Could not create MPRIS player: %s\n", e.message);
		    	}
	    	}

		public void set_station(RadioStation s){
			current_station = s;
			player.set_metadata(current_station.ID, current_station.Icon, current_station.Title);
		}

		private void on_name_acquired(DBusConnection connection, string name) {}	
		private void on_name_lost(DBusConnection connection, string name) {}
	}
    
	[DBus(name = "org.mpris.MediaPlayer2.Player")]
	public class MprisPlayer : GLib.Object {
		private unowned DBusConnection conn;

		private uint send_property_source = 0;
		private uint update_metadata_source = 0;
		private HashTable<string,Variant> changed_properties = null;
		private HashTable<string,Variant> _metadata = null;
		private string playback_status = "Playing";
		private const string INTERFACE_NAME = "org.mpris.MediaPlayer2.Player";

		public MprisPlayer(DBusConnection conn) {
			this.conn = conn;
		}

		public void set_metadata (string station_id, string station_icon, string station_name) {
			if(_metadata != null)
				_metadata = null;

			string[] artists = {station_name};
			_metadata = new HashTable<string, Variant> (null, null);

			_metadata.insert("mpris:trackid", station_id);
			_metadata.insert("mpris:artUrl", station_icon);
			_metadata.insert("xesam:artist", artists);

			if(App.player.tag_title != null)
				_metadata.insert("xesam:title", App.player.tag_title);

			trigger_metadata_update();
		}


		private bool send_property_change() {
			if(changed_properties == null)
			    return false;
			
			var builder             = new VariantBuilder(VariantType.ARRAY);
			var invalidated_builder = new VariantBuilder(new VariantType("as"));
			
			foreach(string name in changed_properties.get_keys()) {
			    Variant variant = changed_properties.lookup(name);
			    builder.add("{sv}", name, variant);
			}
			
			changed_properties = null;
			
			try {
			    conn.emit_signal (null,
			                      "/org/mpris/MediaPlayer2", 
			                      "org.freedesktop.DBus.Properties", 
			                      "PropertiesChanged", 
			                      new Variant("(sa{sv}as)", 
			                                 INTERFACE_NAME, 
			                                 builder, 
			                                 invalidated_builder)
			                     );
			}
			catch(Error e) {
			    print("Could not send MPRIS property change: %s\n", e.message);
			}
			send_property_source = 0;
			return false;
		}
		    

		private void queue_property_for_notification(string property, Variant val) {
			if(changed_properties == null)
			    changed_properties = new HashTable<string,Variant>(str_hash, str_equal);
			
			changed_properties.insert(property, val);
			
			if(send_property_source == 0) {
			    send_property_source = Idle.add(send_property_change);
			}
		}

		private void trigger_metadata_update(){
			if(_metadata != null){
				if(update_metadata_source != 0)
				    Source.remove(update_metadata_source);

				update_metadata_source = Timeout.add(300, () => {
				    Variant variant = this.PlaybackStatus;
				    queue_property_for_notification("PlaybackStatus", variant);
				    queue_property_for_notification("Metadata", _metadata);
				    update_metadata_source = 0;
				    return false;
				});
			}else{
				warning("MPRIS metadata is null");
			}
		}

		public void set_playback_status(string status)
		{
		    	this.playback_status = status;
			trigger_metadata_update();
		}


		public bool CanPlay {
			get {
				return true;
			}
		}

		public bool CanControl {
			get {
				return true;
			}
		}


		public void PlayPause() {
			App.player.toggle_play_stop();
		}

		public void Stop() {
		    	App.player.stop();
		}

		public void Play() {
		    	App.player.play();
		}

		public string PlaybackStatus {
		    	get {
		    		return playback_status;
			}
		}

		/*public HashTable<string,Variant>? Metadata {
			owned get {
			    return _metadata;
			}
		}*/
	}

	[DBus(name = "org.mpris.MediaPlayer2")]
	public class MprisRoot : GLib.Object {
		public bool CanQuit { 
			get {
				return false;
			} 
		}

		public bool CanRaise { 
			get {
			    return false;
			} 
		}
	    
		public string DesktopEntry { 
			owned get {
			    return "gradio";
			} 
		}
	    
		public bool HasTrackList {
			get {
			    return false;
			}
		}
	    
		public string Identity {
			owned get {
			    return "gradio";
			}
		}
	    

		public void Quit () {
			//message("MPRIS: quit");
	    	}
	    
		public void Raise () {
			//message("MPRIS: raise");
		}
	}


    
}

