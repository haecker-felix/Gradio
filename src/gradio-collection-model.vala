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

	public class CollectionModel : GLib.Object, GLib.ListModel {

		private GLib.GenericArray<Collection> collections = new GLib.GenericArray<Collection> ();

		// no items are available
		public signal void empty();

		// items got cleared (ALL ITEMS)
		public signal void cleared();

		public CollectionModel(){
			// Detect if array is empty
			this.items_changed.connect(() => {
				if(collections.length == 0)

					empty();
			});
		}

  		public GLib.Object? get_item (uint index) {
    			return collections.get (index);
  		}

  		public string get_id_by_name (string name){
			int items = (int)get_n_items();

			for(int i = 0; i < items; i++){
				Collection coll = (Collection)get_item(i);
				if(name == coll.name)
					return coll.id;
			}

			return "";
		}

		public Collection get_collection_by_id(string id){
			int items = (int)get_n_items();

			for(int i = 0; i < items; i++){
				Collection coll = (Collection)get_item(i);
				if(id == coll.id)
					return coll;
			}

			return null;
		}

  		public GLib.Type get_item_type () {
    			return typeof (Collection);
  		}

 		public uint get_n_items () {
    			return collections.length;
  		}

  		public bool contains_collection (Collection collection) {
			for (int i = 0; i < collections.length; i ++) {
      				Collection ncollection = collections.get (i);
      				if (collection.id == ncollection.id || collection.name == ncollection.name)
        				return true;
			}

	    		return false;
	  	}

	  	public void add_collection(Collection collection) {
			collections.add (collection);

			this.items_changed (collections.length-1, 0, 1);
	  	}

		public void remove_collection (Collection collection) {
			int pos = 0;
			for (int i = 0; i < collections.length; i ++) {
        				Collection fcollection = collections.get (i);
        				if (fcollection.id == collection.id) {
        					pos = i;
        					break;
        				}
			}

			collections.remove_index (pos);
			items_changed (pos, 1, 0);
	  	}

	  	public void clear () {
	  		uint s = collections.length;
			collections.remove_range(0, collections.length);

			cleared();
	    		this.items_changed (0, s, 0);
	  	}
	}
}

