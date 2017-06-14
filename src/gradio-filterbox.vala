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

	public enum Category{
		LANGUAGES,
		COUNTRIES,
		CODECS,
		STATES
	}

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/filter-box.ui")]
	public class FilterBox : Gtk.Box{

		private StackList filter_stacklist;
		[GtkChild] private Gtk.Box AddFiltersBox;
		[GtkChild] private Gtk.ListBox SelectedFiltersListBox;
		[GtkChild] private ToggleButton AddFiltersToggleButton;
		[GtkChild] private Stack FilterStack;
		[GtkChild] private Label ActualPageLabel;

		public GenericModel selected_filters;
		public GenericModel selected_languages;
		public GenericModel selected_countries;
		public GenericModel selected_codecs;
		public GenericModel selected_states;

		private Category current_category;

		public FilterBox(){
			selected_filters = new GenericModel();
			selected_languages = new GenericModel();
			selected_countries = new GenericModel();
			selected_codecs = new GenericModel();
			selected_states = new GenericModel();

			filter_stacklist = new StackList();
			filter_stacklist.set_visible(true);
			AddFiltersBox.add(filter_stacklist);

			filter_stacklist.push(get_row("Categories", true), CategoryItemProvider.categories_model, (item) => {
				GenericItem generic_item = (GenericItem)item;
				return get_row(generic_item.text);
			});

			SelectedFiltersListBox.bind_model(selected_filters, (item) => {
				GenericItem generic_item = (GenericItem)item;
				return get_row(generic_item.text);
			});

			show_selected_page();

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
					}); current_category = Category.LANGUAGES; break;
				}
				case "Countries": {
					filter_stacklist.push(get_row("Countries", true), CategoryItemProvider.countries_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); current_category = Category.COUNTRIES; break;
				}
				case "Codecs": {
					filter_stacklist.push(get_row("Codecs", true), CategoryItemProvider.codecs_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); current_category = Category.CODECS; break;
				}
				case "States": {
					filter_stacklist.push(get_row("States", true), CategoryItemProvider.states_model, (item) => {
						GenericItem generic_item = (GenericItem)item;
						return get_row(generic_item.text);
					}); current_category = Category.STATES; break;
				}
				default: {
					GenericItem item = new GenericItem(selected);
					selected_filters.add_item(item);

					switch(current_category){
						case Category.LANGUAGES: {selected_languages.add_item(item); break;}
						case Category.COUNTRIES: {selected_countries.add_item(item); break;}
						case Category.CODECS: {selected_codecs.add_item(item); break;}
						case Category.STATES: {selected_states.add_item(item); break;}
					}

					filter_stacklist.pop();
					show_selected_page();
					AddFiltersToggleButton.set_active(false);
					break;
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
				image = new Image.from_icon_name("view-grid-symbolic", Gtk.IconSize.MENU);
				image.margin = 5;
				box.add(image);
				label.set_markup("<b>"+text+"</b>");
				rowbox.pack_end(sep);
			}
			label.margin = 5;

			row.add(rowbox);
			box.add(label);

			row.height_request = 40;
			row.set_data("ITEM", text);
			row.show_all();

			sep.set_halign(Align.FILL);
			sep.set_valign(Align.END);

			return row;
		}

		[GtkCallback]
		private void ClearFiltersButton_clicked(Button button){
			selected_filters.clear();
			selected_languages.clear();
			selected_countries.clear();
			selected_codecs.clear();
			selected_states.clear();
		}

		[GtkCallback]
		private void AddFiltersToggleButton_toggled(){

			if(AddFiltersToggleButton.get_active()){
				show_add_page();
			}else{
				show_selected_page();
			}
		}

		private void show_add_page(){
			FilterStack.set_visible_child_name("add");
			ActualPageLabel.set_text("Add a filter:");
		}

		private void show_selected_page(){
			FilterStack.set_visible_child_name("selected");
			ActualPageLabel.set_text("Search filters:");
		}
	}
}
