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

namespace Gradio{

	public class StationModel : GLib.Object, GLib.ListModel {
		private ListStore stations;

		// items got cleared (ALL ITEMS)
		public signal void cleared();

		public StationModel(){
			stations = new ListStore (typeof (RadioStation));
			App.settings.notify["station-sorting"].connect(sort);
			App.settings.notify["sort-ascending"].connect(sort);

			stations.items_changed.connect((position, removed, added) => {
				items_changed (position, removed, added);
			});
		}

  		public GLib.Object? get_item (uint index) {
    			return stations.get_item (index);
  		}

  		public GLib.Type get_item_type () {
    			return typeof (RadioStation);
  		}

 		public uint get_n_items () {
    			return stations.get_n_items();
  		}

  		public bool contains_station (RadioStation station) {
			for (int i = 0; i < stations.get_n_items(); i ++) {
      				RadioStation fstation = (RadioStation)stations.get_item (i);
      				if (station.id == fstation.id) return true;
			}
	    		return false;
	  	}

	  	public void add_station(RadioStation station) {
			StationCompare scompare = new StationCompare();
	  		stations.insert_sorted(station, scompare.compare);
	  	}

		public void remove_station (RadioStation station) {
			for (int i = 0; i < stations.get_n_items(); i ++) {
       				RadioStation fstation = (RadioStation)stations.get_item (i);
       				if (fstation.id == station.id) {
       					stations.remove (i);
       					break;
       				}
			}
	  	}

		public RadioStation get_next_station(RadioStation current){
			RadioStation next = null; int current_index = 0;

			// find out the index of the current station
			for (int i = 0; i < stations.get_n_items(); i ++) {
      				RadioStation found_station = (RadioStation)stations.get_item (i);
      				if (current.id == found_station.id){
      					current_index = i; break;
      				}
			}

			if(current_index+1 < stations.get_n_items())
				next =  (RadioStation)stations.get_item (current_index+1);
			else
				next = (RadioStation)stations.get_item (0);

			return next;
		}

		public RadioStation get_previous_station(RadioStation current){
			RadioStation previous = null; int current_index = 0;

			// find out the index of the current station
			for (int i = 0; i < stations.get_n_items(); i ++) {
      				RadioStation found_station = (RadioStation) stations.get_item (i);
      				if (current.id == found_station.id){
      					current_index = i; break;
      				}
			}

			if(current_index-1 != -1)
				previous =  (RadioStation) stations.get_item(current_index-1);
			else
				previous = (RadioStation) stations.get_item(stations.get_n_items()-1);

			return previous;
		}

	  	public void clear () {
			stations.remove_all();
			cleared();
	  	}

	  	private void sort(){
			StationCompare scompare = new StationCompare();
	  		stations.sort(scompare.compare);
	  	}
	}
}

