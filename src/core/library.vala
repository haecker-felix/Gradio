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

	public class Library : Gtk.Box{
		public signal void added_radio_station(RadioStation s);
		public signal void removed_radio_station(RadioStation s);

		public HashTable<int,RadioStation> lib;

		private StationProvider provider;

		string data_path;
		string dir_path;

		public Library(){
			lib = new HashTable<int,RadioStation>(direct_hash, direct_equal);
			provider = new StationProvider();

			data_path = Path.build_filename (Environment.get_user_data_dir (), "gradio", "library.gradio");
			dir_path = Path.build_filename (Environment.get_user_data_dir (), "gradio");

			added_radio_station.connect(() => write_data());
			removed_radio_station.connect(() => write_data());
		}

		public bool contains_station(int id){
			if(lib[id] != null)
				return true;
			else
				return false;
		}

		public void add_radio_station_by_id(int id){
			RadioStation station = provider.parse_station_data_from_id(id);
			lib[id] = station;

			added_radio_station(station);
		}

		public void remove_radio_station_by_id(int id){
			RadioStation station = provider.parse_station_data_from_id(id);
			lib.remove(station.ID);

			removed_radio_station(station);
		}

		public void add_radio_station(RadioStation station){
			lib[station.ID] = station;

			added_radio_station(station);
		}

		public void remove_radio_station(RadioStation station){
			lib.remove(station.ID);

			removed_radio_station(station);
		}

		public void write_data (){
			message("Writing library data to: " + data_path);

			try{
				var file = File.new_for_path (data_path);
				var dir = File.new_for_path (dir_path);

				if(!file.query_exists ()){
					if(!dir.query_exists ()){
						message("Creating gradio data folder...");
						dir.make_directory_with_parents ();
					}
					file.create (FileCreateFlags.NONE);
				}else{
					file.delete();
					file.create (FileCreateFlags.NONE);
				}

				FileIOStream iostream = file.open_readwrite ();
				iostream.seek (0, SeekType.END);

				OutputStream ostream = iostream.output_stream;
				DataOutputStream dostream = new DataOutputStream (ostream);

				lib.foreach ((key, val) => {
					try {
						dostream.put_string (key.to_string()+"\n");
					} catch (GLib.IOError e) {
						error(e.message);
					}
				});
			}catch(Error e){
				error(e.message);
			}
		}

		public void read_data (){
			message("Reading library data from: " + data_path);

			try{
				var file = File.new_for_path (data_path);

				if(file.query_exists ()){
					var dis = new DataInputStream (file.read ());
					string line;

					while ((line = dis.read_line (null)) != null) {

						RadioStation station = provider.parse_station_data_from_id(int.parse(line));

						if(station != null){
							lib[int.parse(line)] = station;
						}

					}
				}else{
					message("No gradio library found. ");
				}
			}catch(Error e){
				error(e.message);
			}

			message("Successfully imported library");

		}

	}
}
