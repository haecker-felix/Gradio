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
	public class GenericItem : GLib.Object {

		public string text;

		public GenericItem (string t) {
			text = t;
		}
	}

	public class GenericModel : GLib.Object, GLib.ListModel {

		private GLib.GenericArray<GenericItem> items = new GLib.GenericArray<GenericItem> ();

		public GenericModel(){}

		public void clear(){
			uint s = items.length;
			items.remove_range(0, items.length);
	    		this.items_changed (0, s, 0);
		}

  		public GLib.Object? get_item (uint index) {
    			return items.get (index);
  		}

  		public GLib.Type get_item_type () {
    			return typeof (GenericItem);
  		}

 		public uint get_n_items () {
    			return items.length;
  		}

	  	public void add_item(GenericItem item) {
			items.add (item);
			this.items_changed (items.length-1, 0, 1);
	  	}

		public void remove_item (GenericItem item) {
			int pos = 0;
			for (int i = 0; i < items.length; i ++) {
        				GenericItem fitem = items.get (i);
        				if (fitem.text == item.text) {
        					pos = i;
        					break;
        				}
			}

			items.remove_index (pos);
			items_changed (pos, 1, 0);
	  	}
	}
}
