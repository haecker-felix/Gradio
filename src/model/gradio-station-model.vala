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

	  	public void add_item(Gd.MainBoxItem item) {
	  		StationCompare scompare = new StationCompare();
	  		items.insert_sorted(item, scompare.compare);
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
	  		// TODO: Port the sorting system to the new model. Collection items are currently not sortable
			StationCompare scompare = new StationCompare();
	  		items.sort(scompare.compare);
	  	}

	  	public string get_id_by_name (string name){
	  		for (int i = 0; i < get_n_items(); i ++) {
	  			Gd.MainBoxItem item = (Gd.MainBoxItem)get_item(i);

	  			if(Util.is_collection_item(int.parse(item.id))){
					if(name == ((Collection)item).name) return item.id;
	  			}else{
					if(name == ((RadioStation)item).title) return item.id;
				}
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

		public bool contains_radio_station_item(){
			for (int i = 0; i < get_n_items(); i ++) {
      				Gd.MainBoxItem fitem = (Gd.MainBoxItem)get_item (i);
      				if (!Util.is_collection_item(int.parse(fitem.id))) return true;
			}
			return false;
		}

		public bool contains_collection_item(){
			for (int i = 0; i < get_n_items(); i ++) {
      				Gd.MainBoxItem fitem = (Gd.MainBoxItem)get_item (i);
      				if (Util.is_collection_item(int.parse(fitem.id))) return true;
			}
			return false;
		}

		public bool contains_item_with_id(string id){
			for (int i = 0; i < get_n_items(); i ++) {
      				Gd.MainBoxItem fitem = (Gd.MainBoxItem)get_item (i);
      				if (fitem.id == id) return true;
			}
			return false;
		}

		public Iterator iterator() {
			return new Iterator(this);
		}

		public class Iterator {
			private int index;
			private StationModel model;

			public Iterator(StationModel model) {
				this.model = model;
			}

			public bool next() {
				if(index < model.get_n_items())
					return true;
				else
					return false;
			}

			public Gd.MainBoxItem get() {
				this.index++;
				return (Gd.MainBoxItem)this.model.get_item(this.index - 1);
			}
		}
	}
}

