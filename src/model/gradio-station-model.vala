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
		private ListStore items;

		// items got cleared (ALL ITEMS)
		public signal void cleared();

		public StationModel(){
			items = new ListStore (typeof (Gd.MainBoxItem));
			App.settings.notify["station-sorting"].connect(sort);
			App.settings.notify["sort-ascending"].connect(sort);

			items.items_changed.connect((position, removed, added) => {
				items_changed (position, removed, added);
			});
		}

  		public GLib.Object? get_item (uint index) {
    			return items.get_item (index);
  		}

  		public GLib.Type get_item_type () {
    			return typeof (Gd.MainBoxItem);
  		}

 		public uint get_n_items () {
    			return items.get_n_items();
  		}

  		public bool contains_item (Gd.MainBoxItem item) {
			for (int i = 0; i < get_n_items(); i ++) {
      				Gd.MainBoxItem fitem = (Gd.MainBoxItem)get_item (i);
      				if (item.id == fitem.id) return true;
			}
	    		return false;
	  	}

	  	public void add_item(Gd.MainBoxItem item) {
	  		items.insert(0, item);
	  	}

		public void remove_item (Gd.MainBoxItem item) {
			for (int i = 0; i < items.get_n_items(); i ++) {
       				Gd.MainBoxItem fitem = (Gd.MainBoxItem)items.get_item (i);
       				if (fitem.id == item.id) {
       					items.remove (i);
       					break;
       				}
			}
	  	}

	  	public void clear () {
			items.remove_all();
			cleared();
	  	}

	  	private void sort(){
			StationCompare scompare = new StationCompare();
	  		items.sort(scompare.compare);
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

		public Gd.MainBoxItem get_item_by_id(string id){
			for (int i = 0; i < get_n_items(); i ++) {
      				Gd.MainBoxItem fitem = (Gd.MainBoxItem)get_item (i);
      				if (id == fitem.id) return fitem;
			}

			return null;
		}
	}
}

