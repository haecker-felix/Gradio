using Gee;

namespace Gradio{

	public class Library : Gtk.Box{

		GradioApp app;

		public signal void added_radio_station();
		public signal void removed_radio_station();

		public HashMap<int,RadioStation> lib;

		public Library(ref GradioApp a){
			app = a;
			lib = new HashMap<int,RadioStation>();
		}		
	
		public bool contains_station(int id){
			if(lib[id] != null)
				return true;
			else
				return false;
		}

		public void add_radio_station_by_id(int id){
			RadioStation station = new RadioStation.parse_from_id(id);
			lib[id] = station;

			added_radio_station();
		}

		public void remove_radio_station_by_id(int id){
			RadioStation station = new RadioStation.parse_from_id(id);
			lib.unset(int.parse(station.ID));

			removed_radio_station();
		}

		public void add_radio_station(RadioStation station){
			lib[int.parse(station.ID)] = station;

			added_radio_station();
		}

		public void remove_radio_station(RadioStation station){
			lib.unset(int.parse(station.ID));

			removed_radio_station();
		}

	}
}
