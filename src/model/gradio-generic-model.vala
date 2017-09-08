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
		private ListStore items;

		public GenericModel(){
			items = new ListStore (typeof (GenericItem));

			items.items_changed.connect((position, removed, added) => {
				items_changed (position, removed, added);
			});
		}

  		public GLib.Object? get_item (uint index) {
    			return items.get_item (index);
  		}

  		public GLib.Type get_item_type () {
    			return typeof (GenericItem);
  		}

 		public uint get_n_items () {
    			return items.get_n_items();
  		}

	  	public void add_item(GenericItem item) {
			items.append (item);
	  	}

		public void remove_item (GenericItem item) {
			for (int i = 0; i < items.get_n_items(); i ++) {
        			GenericItem fitem = (GenericItem)items.get_item (i);
        			if (fitem.text == item.text) {
        				items.remove (i);
        				break;
        			}
			}
	  	}
	}
}
