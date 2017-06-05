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

		private int depth = 0;
		// 0: Set filter...
		// 1: Languages, Countries...
		// 2: Germany, England, Russia...

		public FilterBox(){
			filter_stacklist = new StackList();
			filter_stacklist.width_request = 250;
			this.add(filter_stacklist);

			filter_stacklist.push(get_label("Categories", true), CategoryItemProvider.categories_model, (item) => {
				GenericItem generic_item = (GenericItem)item;
				return get_label(generic_item.text);
			});

			this.show_all();
			connect_signals();
		}

		private void connect_signals(){
			filter_stacklist.row_activated.connect(row_activated);
		}

		private void row_activated(ListBoxRow row){
			Gtk.Label row_label = (Gtk.Label)row.get_child();
			string selected = row_label.get_text();

			switch(selected){
				case "Languages": {
					filter_stacklist.push(get_label("Languages", true), CategoryItemProvider.languages_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_label(generic_item.text);
					}); break;
				}
				case "Countries": {
					filter_stacklist.push(get_label("Countries", true), CategoryItemProvider.countries_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_label(generic_item.text);
					}); break;
				}
				case "Codecs": {
					filter_stacklist.push(get_label("Codecs", true), CategoryItemProvider.codecs_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_label(generic_item.text);
					}); break;
				}
				case "States": {
					filter_stacklist.push(get_label("States", true), CategoryItemProvider.states_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_label(generic_item.text);
					}); break;
				}
				case "Tags": {
					filter_stacklist.push(get_label("Tags", true), CategoryItemProvider.tags_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_label(generic_item.text);
					}); break;
				}
			}
		}

		private Gtk.Label get_label(string text, bool header = false){
			Label l = new Label (text);

			if(header){
				l.set_markup("<b>"+text+"</b>");
			}

			l.height_request = 30;
			l.set_halign(Align.START);
			l.set_visible(true);

			return l;
		}
	}
}
