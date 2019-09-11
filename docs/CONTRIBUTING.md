# Contribute
All contributions are welcome (artwork, design, code, just ideas, etc.) but if you're planning to actively change something bigger, talk to me first.

## Filing a bug
Please file bugs for issues, enhancements and features on
[Github](https://github.com/haecker-felix/gradio/issues/new)
bug tracker.

## Translation
To translate Gradio, please use [Weblate](https://hosted.weblate.org/engage/gradio/).

## Asking for Help
Currently there isn't much documentation available for Gradio. If you have a question, please contact me: haeckerfelix@gnome.org

## Licensing
Contributions should be licensed under the LGPL-2.1+ or GPL-3.

## Coding Style
Please continue using this coding style:
```vala
public async string get_stream_address (){
	SourceFunc callback = get_stream_address.callback;
	string url = "";
  
	Util.get_string_from_uri.begin(RadioBrowser.radio_station_stream_url + _id, (obj, res) => {
		string result = Util.get_string_from_uri.end(res);

		if(result != null)
			data = result;
		Idle.add((owned) callback);
	});

	yield;

	try{
		Json.Parser parser = new Json.Parser ();

		parser.load_from_data (data);
		var root = parser.get_root ();
		if(root != null){
			var radio_station_data = root.get_object ();
			if(radio_station_data.get_string_member("ok") ==  "true"){
				url = radio_station_data.get_string_member("url");
			}
		}

	}catch(GLib.Error e){
		warning(e.message);
	}

	return url;
}
```
