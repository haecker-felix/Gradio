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

		private ListStore collections;

		// no items are available
		public signal void empty();

		// items got cleared (ALL ITEMS)
		public signal void cleared();

		public CollectionModel(){
			collections = new ListStore (typeof (Collection));

			// Detect if array is empty
			collections.items_changed.connect((position, removed, added) => {
				if(collections.get_n_items() == 0) empty();
				items_changed (position, removed, added);
			});
		}

  		public GLib.Object? get_item (uint index) {
    			return collections.get_item (index);
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
			Collection collection = null;

			for(int i = 0; i < items; i++){
				Collection coll = (Collection)get_item(i);
				if(id == coll.id)
					collection = coll;
			}

			return collection;
		}

  		public GLib.Type get_item_type () {
    			return typeof (Collection);
  		}

 		public uint get_n_items () {
    			return collections.get_n_items();
  		}

  		public bool contains_collection (Collection collection) {
			for (int i = 0; i < collections.get_n_items(); i ++) {
      				Collection ncollection = (Collection)collections.get_item (i);
      				if (collection.id == ncollection.id || collection.name == ncollection.name)
        				return true;
			}

	    		return false;
	  	}

	  	public void add_collection(Collection collection) {
			collections.append (collection);
	  	}

		public void remove_collection (Collection collection) {
			for (int i = 0; i < collections.get_n_items(); i ++) {
        			Collection fcollection = (Collection)collections.get_item (i);
        			if (fcollection.id == collection.id) {
        				collections.remove (i);
        				break;
        			}
			}
	  	}

	  	public void clear () {
	  		collections.remove_all();
	  	}
	}
}

