namespace Gradio{
	public class RadioStation{

		public string Title = "";
		public string Homepage = "";
		public string Source = "";
		public string Language = "";
		public string ID = "";
		public string Icon = "";
		public string Country = "";
		public string Tags = "";
		public string State = "";
		public string Votes = "";
		public string Codec = "";
		public string Bitrate = "";
		public string DataAddress = "";
		public bool Available = false;

		public signal void data_changed();

		public RadioStation(string title, string homepage, string source, string language, string id, string icon, string country, string tags, string state, string votes, string codec, string bitrate, bool available){
			Title = title;
			Homepage = homepage;
			Source = source;
			Language = language;
			ID = id;
			Icon = icon;
			Country = country;
			Tags = tags;
			State = state;
			Votes = votes;
			Codec = codec;
			Bitrate = bitrate;
			Available = available;
		}

		public void vote (){
			DataProvider dataprovider = new DataProvider();
			Votes = dataprovider.vote_for_station(this).to_string();
			data_changed();
		}
	}
}
