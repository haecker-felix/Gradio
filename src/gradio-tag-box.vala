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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/tag-box.ui")]
	public class TagBox : Gtk.Box{

		private int max = -1;

		public TagBox(){

		}

		public void set_max(int m){
			max = m;
		}

		public void set_tags(string txt){
			Util.remove_all_items_from_box(this);

			string[] tags = txt.split (",");

			if(max == -1){
				foreach(string tag in tags){
					Label l = new Label(" "+tag+" ");
					this.add(l);
				}
			}else{
				int counter = 0;
				foreach(string tag in tags){

					if(counter != max){
						Label l = new Label(" "+tag+" ");
						this.add(l);
					}else{
						Label l = new Label(" ... ");
						this.add(l);

						this.show_all();
						return;
					}

					counter++;
				}
			}

			this.show_all();
		}

	}
}
