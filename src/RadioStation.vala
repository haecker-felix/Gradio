namespace Gradio{
	public class RadioStation{

		public string Title = "";
		public string Homepage = "";
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
		public bool Broken = true;

		public signal void data_changed();

		public RadioStation(string title, string homepage, string language, string id, string icon, string country, string tags, string state, string votes, string codec, string bitrate, bool broken){
			Title = title;
			Homepage = homepage;
			Language = language;
			ID = id;
			Icon = icon;
			Country = country;
			Tags = tags;
			State = state;
			Votes = votes;
			Codec = codec;
			Bitrate = bitrate;
			Broken = broken;

			if(Broken)
				Title = "[BROKEN] " + Title;
		}

		public void vote (){
			Votes = App.data_provider.vote_for_station(this).to_string();
			data_changed();
		}
	}
}
