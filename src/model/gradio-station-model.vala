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

		private GLib.GenericArray<RadioStation> stations = new GLib.GenericArray<RadioStation> ();

		// no items are available
		public signal void empty();

		// items got cleared (ALL ITEMS)
		public signal void cleared();

		public StationModel(){
			// Detect if array is empty
			this.items_changed.connect(() => {
				if(stations.length == 0)
					empty();
			});
		}

  		public GLib.Object? get_item (uint index) {
    			return stations.get ((int)index);
  		}

  		public GLib.Type get_item_type () {
    			return typeof (RadioStation);
  		}

 		public uint get_n_items () {
    			return stations.length;
  		}

  		public bool contains_station (RadioStation station) {
			for (int i = 0; i < stations.length; i ++) {
      				RadioStation fstation = stations.get (i);
      				if (station.id == fstation.id)
        				return true;
			}

	    		return false;
	  	}

	  	public void add_station(RadioStation station) {
			stations.add (station);

			this.items_changed (stations.length-1, 0, 1);
	  	}

		public void remove_station (RadioStation station) {
			int pos = 0;
			for (int i = 0; i < stations.length; i ++) {
       				RadioStation fstation = stations.get (i);
       				if (fstation.id == station.id) {
       					pos = i;
       					break;
       				}
			}

			stations.remove_index (pos);
			items_changed (pos, 1, 0);
	  	}

		public RadioStation get_next_station(RadioStation current){
			RadioStation next = null;
			int current_index = 0;

			// find out the index of the current station
			for (int i = 0; i < stations.length; i ++) {
      				RadioStation found_station = stations.get (i);
      				if (current.id == found_station.id){
      					current_index = i;
      					break;
      				}
			}

			if(current_index+1 < stations.length)
				next =  stations.get(current_index+1);
			else
				next = stations.get(0);

			return next;
		}

		public RadioStation get_previous_station(RadioStation current){
			RadioStation previous = null;
			int current_index = 0;

			// find out the index of the current station
			for (int i = 0; i < stations.length; i ++) {
      				RadioStation found_station = stations.get (i);
      				if (current.id == found_station.id){
      					current_index = i;
      					break;
      				}
			}

			if(current_index-1 != -1)
				previous =  stations.get(current_index-1);
			else
				previous = stations.get(stations.length-1);

			return previous;
		}

	  	public void clear () {
	  		uint s = stations.length;
			stations.remove_range(0, stations.length);

			cleared();
	    		this.items_changed (0, s, 0);
	  	}
	}
}

