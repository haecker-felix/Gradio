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

using Gtk;
using Dzl;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/filter-box.ui")]
	public class FilterBox : Gtk.Box{

		private StackList filter_stacklist;

		public FilterBox(){
			filter_stacklist = new StackList();
			filter_stacklist.width_request = 250;
			this.add(filter_stacklist);

			filter_stacklist.push(get_row("Categories", true), CategoryItemProvider.categories_model, (item) => {
				GenericItem generic_item = (GenericItem)item;
				return get_row(generic_item.text);
			});

			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
			filter_stacklist.row_activated.connect(row_activated);
		}

		private void row_activated(ListBoxRow row){
			string selected = row.get_data("ITEM");

			switch(selected){
				case "Languages": {
					filter_stacklist.push(get_row("Languages", true), CategoryItemProvider.languages_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); break;
				}
				case "Countries": {
					filter_stacklist.push(get_row("Countries", true), CategoryItemProvider.countries_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); break;
				}
				case "Codecs": {
					filter_stacklist.push(get_row("Codecs", true), CategoryItemProvider.codecs_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); break;
				}
				case "States": {
					filter_stacklist.push(get_row("States", true), CategoryItemProvider.states_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); break;
				}
			}
		}

		private ListBoxRow get_row(string text, bool header = false){
			ListBoxRow row = new ListBoxRow();

			Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			box.vexpand = true;

			Gtk.Box rowbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			rowbox.add(box);

			Label label = new Label (text);
			Image image;

			Separator sep = new Separator(Gtk.Orientation.HORIZONTAL);

			if(header){
				image = new Image.from_icon_name("view-list-symbolic", Gtk.IconSize.MENU);
				label.set_markup("<b>"+text+"</b>");
				rowbox.pack_end(sep);
			}else{
				image = new Image.from_icon_name("text-x-generic-symbolic", Gtk.IconSize.MENU);
			}

			row.add(rowbox);
			box.add(image);
			box.add(label);

			row.height_request = 40;
			row.set_data("ITEM", text);
			row.show_all();

			sep.set_halign(Align.FILL);
			sep.set_valign(Align.END);

			return row;
		}
	}
}
