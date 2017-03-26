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

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/groupbox.ui")]
	public class GroupBox : Gtk.Box{

		[GtkChild]
		private Label Title;

		[GtkChild]
		private ListBox Items;


		public GroupBox(string title){
			Title.set_text(title);
			Items.set_header_func(header_func);

			Label placeholder = new Label("No items available");
			Items.set_placeholder(placeholder);
			placeholder.set_visible(true);

			Items.row_activated.connect((t,a) => {
				GroupBoxItem row = (GroupBoxItem)a;
				row.clicked();
			});
		}

		private void header_func(ListBoxRow row, ListBoxRow? row_before){
			if(row_before == null){
				row.set_header(null);
				return;
			}

			Gtk.Widget current = row.get_header();

			if(current == null){
				current = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
				current.show();
				row.set_header(current);
			}
		}

		public void add_widget(Gtk.Widget widget){
			widget.set_margin_top(6);
			widget.set_margin_bottom(6);
			widget.set_margin_start(6);
			widget.set_margin_end(6);

			WidgetItem row = new WidgetItem(widget);
			row.set_size_request(1,40);

			Items.add(row);
		}

		public void add_listbox_row(Gtk.ListBoxRow row){
			row.set_size_request(1,40);
			Items.add(row);
		}

		public void set_title(string t){
			Title.set_text(t);
		}
	}
}

