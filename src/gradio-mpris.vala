/*-Original Authors: Andreas Obergrusberger
 *		     Jörn Magens
 *
 * Edited by: Felix Häcker for Gradio
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

using GLib;

public class Gradio.MPRIS : GLib.Object {
	public MprisPlayer player = null;
	public MprisRoot root = null;

	private unowned DBusConnection conn;
	private uint owner_id;

	public signal void requested_raise();
	public signal void requested_quit();

	public void initialize() {
		owner_id = Bus.own_name(BusType.SESSION,
					"org.mpris.MediaPlayer2.gradio",
					GLib.BusNameOwnerFlags.NONE,
					on_bus_acquired,
					on_name_acquired,
					on_name_lost);

		if(owner_id == 0) {
			warning("Could not initialize MPRIS session.\n");
		}
	}

	private void on_bus_acquired(DBusConnection connection, string name) {
		this.conn = connection;

		try {
			root = new MprisRoot();
			connection.register_object("/org/mpris/MediaPlayer2", root);
			player = new MprisPlayer(connection);
			connection.register_object("/org/mpris/MediaPlayer2", player);

			root.quit.connect(() => requested_quit());
			root.raise.connect(() => requested_raise());
		}
		catch(IOError e) {
			warning("Could not create MPRIS player: %s\n", e.message);
		}
	}

	private void on_name_acquired(DBusConnection connection, string name) {
		//message("name acquired\n");
	}

	private void on_name_lost(DBusConnection connection, string name) {
		//message("name_lost\n");
	}
}

[DBus(name = "org.mpris.MediaPlayer2")]
public class Gradio.MprisRoot : GLib.Object {

	public signal void raise();
	public signal void quit();

	public bool CanQuit {
		get {
			return true;
		}
	}

	public bool CanRaise {
		get {
			return true;
		}
	}

	public bool CanSetFullscreen {
		get {
			return false;
		}
	}

	public bool Fullscreen {
		get {
			return false;
		}
		set {
			// Can't full screen
		}
	}

	public bool HasTrackList {
		get {
			return false;
		}
	}
	public string DesktopEntry {
		owned get {
			return "de.haeckerfelix.gradio";
		}
	}

	public string Identity {
		owned get {
			return "Gradio";
		}
	}

	public string[] SupportedUriSchemes {
		owned get {
			string[] sa = {"http", "https"};
			return sa;
		}
	}

	public string[] SupportedMimeTypes {
		owned get {
			string[] sa = {
				 "application/x-ogg",
				 "application/ogg",
				 "audio/x-vorbis+ogg",
				 "audio/x-scpls",
				 "audio/x-mp3",
				 "audio/x-mpeg",
				 "audio/mpeg",
				 "audio/x-mpegurl",
				 "audio/x-flac",
				 "x-content/audio-cdda",
				 "x-content/audio-player"
			};
			return sa;
		}
	}

	public void Quit() {
		message("Requested _quit_");
		quit();
	}

	public void Raise() {
		message("Requested _raise_");
		raise();
	}
}


[DBus(name = "org.mpris.MediaPlayer2.Player")]
public class Gradio.MprisPlayer : GLib.Object {
	private unowned DBusConnection conn;

	private const string INTERFACE_NAME = "org.mpris.MediaPlayer2.Player";
	const string TRACK_ID = "/de/haeckerfelix/gradio/Track/%d";

	private uint send_property_source = 0;
	private uint update_metadata_source = 0;
	private HashTable<string,Variant> changed_properties = null;
	private HashTable<string,Variant> _metadata;

	private enum Direction {
		NEXT = 0,
		PREVIOUS,
		STOP
	}

	public MprisPlayer(DBusConnection conn) {
		this.conn = conn;
		_metadata = new HashTable<string,Variant>(str_hash, str_equal);

		App.player.notify["current-title-tag"].connect (song_changed);
		App.player.notify["state"].connect (playing_changed);
	}

	private void fill_metadata() {
		if(App.player.station != null){
			string[] artists = {App.player.station.title};

			if(App.player.current_title_tag != null)
				_metadata.insert("xesam:title", App.player.current_title_tag);

			_metadata.insert("mpris:artUrl", App.player.station.icon_address);
			_metadata.insert("xesam:artist", artists);
		}
	}

	private void song_changed () {
		fill_metadata ();
		trigger_metadata_update ();
	}

	private void playing_changed () {
		trigger_metadata_update ();
	}

	private void trigger_metadata_update() {
		if(update_metadata_source != 0)
			Source.remove(update_metadata_source);

			update_metadata_source = Timeout.add(300, () => {
			Variant variant = this.PlaybackStatus;

			queue_property_for_notification("PlaybackStatus", variant);
			queue_property_for_notification("Metadata", _metadata);
			update_metadata_source = 0;
			return false;
		});
	}

	private bool send_property_change() {
		if(changed_properties == null)
			return false;

		var builder = new VariantBuilder(VariantType.ARRAY);
		var invalidated_builder = new VariantBuilder(new VariantType("as"));

		foreach(string name in changed_properties.get_keys()) {
			Variant variant = changed_properties.lookup(name);
			builder.add("{sv}", name, variant);
		}

		changed_properties = null;

		try {
			conn.emit_signal(null,
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

	public string PlaybackStatus {
		owned get {
			if (App.player.state == Gst.State.PLAYING)
				return "Playing";
			else
				return "Paused";
		}
	}

	public double Rate {
		get {
			return (double)1.0;
		}
		set {

		}
	}

	public bool Shuffle {
		get {
			return false;
		}
		set {

		}
	}

	public HashTable<string,Variant>? Metadata { //a{sv}
		owned get {
			fill_metadata();

			return _metadata;
		}
	}

	public double Volume {
		get{
			return App.player.volume;
		}
		set {
			App.player.volume = value;
		}
	}

	public double MinimumRate {
		get {
			return (double)1.0;
		}
	}

	public double MaximumRate {
		get {
			return (double)1.0;
		}
	}

	public bool CanGoNext {
		get {
			return true;
		}
	}

	public bool CanGoPrevious {
		get {
			return true;
		}
	}

	public bool CanPlay {
		get {
			return !(App.player.state == Gst.State.PLAYING);
		}
	}

	public bool CanPause {
		get {
			return (App.player.state == Gst.State.PLAYING);
		}
	}

	public bool CanSeek {
		get {
			return false;
		}
	}

	public bool CanControl {
		get {
			return false;
		}
	}

	public signal void Seeked(int64 Position);

	public void Next() {
		RadioStation current = App.player.station;
		App.player.station = Library.station_model.get_next_station(current);

	}

	public void Previous() {
		RadioStation current = App.player.station;
		App.player.station = Library.station_model.get_previous_station(current);
	}

	public void Pause() {
		App.player.state = Gst.State.NULL;
	}

	public void PlayPause() {
		App.player.toggle_play_stop ();
	}

	public void Stop() {
		App.player.state = Gst.State.NULL;
	}

	public void Play() {
		App.player.state = Gst.State.PLAYING;
	}

	public void OpenUri(string Uri) {

	}
}

