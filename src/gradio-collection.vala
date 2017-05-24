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

using Gdk;

namespace Gradio{
	public class Collection : GLib.Object, Gd.MainBoxItem{
		private string _name;
		private string _id;
		private string _uri;
		private bool _pulse;
		private int64 _mtime;
		private Cairo.Surface _icon;

		public StationModel station_model;
		private StationProvider station_provider;

		public string id {
			get{return _id;}
		}

		public string name {
			get{return _name;}
		}

		public string uri {
			get{return _uri;}
		}

		public string primary_text {
			get{
				return _name;
			}
		}

		public string secondary_text {
			get{return "";}
		}

		public bool pulse {
			get{return _pulse;}
		}

		public int64 mtime {
			get{return _mtime;}
		}

		public Cairo.Surface icon {
			get{
				List<Gdk.Pixbuf> pixbufs = new List<Gdk.Pixbuf>();

				Gdk.Pixbuf pix1 = new Gdk.Pixbuf.from_resource("/de/haecker-felix/gradio/icons/hicolor/48x48/apps/de.haeckerfelix.gradio.png");
				Gdk.Pixbuf pix2 = new Gdk.Pixbuf.from_resource("/de/haecker-felix/gradio/icons/hicolor/48x48/apps/de.haeckerfelix.gradio.png");
				Gdk.Pixbuf pix3 = new Gdk.Pixbuf.from_resource("/de/haecker-felix/gradio/icons/hicolor/48x48/apps/de.haeckerfelix.gradio.png");
				Gdk.Pixbuf pix4 = new Gdk.Pixbuf.from_resource("/de/haecker-felix/gradio/icons/hicolor/48x48/apps/de.haeckerfelix.gradio.png");

				pixbufs.append(pix1);
				pixbufs.append(pix2);
				pixbufs.append(pix3);
				pixbufs.append(pix4);

				_icon = Util.create_thumbnail(192, pixbufs);

				return _icon;
			}
		}

		public Collection(string n, string i){
			_name = n;
			_id = i;

			station_model = new StationModel();
			station_provider = new StationProvider(ref station_model);
		}

		private void update_icon(){
                	notify_property("icon");

		}

		public void add_station(RadioStation station){
			station_model.add_station(station);
			update_icon();
		}

		public void add_station_by_id(int id){
			station_provider.add_station_by_id(id);
			update_icon();
		}

		public void remove_station(RadioStation station){
			station_model.remove_station(station);
		}
	}
}
