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

	public interface Page : Gtk.Box{

		public virtual string get_title(){
			return "";
		}

		public virtual void set_selection_mode(bool b){}
		public virtual void select_all(){}
		public virtual void select_none(){}

		public signal void selection_mode_enabled();
		public signal void selection_changed();
		public virtual GLib.List<Gd.MainBoxItem> get_selection(){
			List<Gd.MainBoxItem> item = null;
			return item;
		}

	}
}
