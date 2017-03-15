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

using Sqlite;

namespace Gradio{

	public class Library : Gtk.Box{
		public signal void added_radio_station(RadioStation s);
		public signal void removed_radio_station(RadioStation s);

		private StationProvider station_provider;
		public static StationModel library_model;

		private Sqlite.Database db;
		private string db_error_message;

		string database_path;
		string data_path;
		string dir_path;

		public Library(){
			database_path = Path.build_filename (Environment.get_user_data_dir (), "gradio", "gradio.db");
			data_path = Path.build_filename (Environment.get_user_data_dir (), "gradio", "library.gradio");
			dir_path = Path.build_filename (Environment.get_user_data_dir (), "gradio");

			library_model = new StationModel();
			station_provider = new StationProvider(ref library_model);

			open_database();
		}

		public bool contains_station(RadioStation station){
			if(library_model.contains_station(station))
				return true;
			else
				return false;
		}


		public bool add_radio_station(RadioStation station){
			string query = "INSERT INTO library (station_id,folder_id) VALUES ("+station.ID.to_string()+", '0');";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not add item to database: %s\n", db_error_message);
				return false;
			}else{
				library_model.add_station(station);
				added_radio_station(station);
				return true;
			}
		}

		public bool remove_radio_station(RadioStation station){
			string query = "DELETE FROM library WHERE station_id=" + station.ID.to_string();

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not remove item from database: %s\n", db_error_message);
				return false;
			}else{
				library_model.remove_station(station);
				removed_radio_station(station);
				return true;
			}
		}


		private void open_database(){
			message("Open database...");

			File file = File.new_for_path (database_path);

			if(!file.query_exists()){
				message("No database found.");
				create_database();
				return;
			}

			int return_code = Sqlite.Database.open (database_path.to_string(), out db);

			if (return_code!= Sqlite.OK) {
				critical ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
				return;
			}

			read_database();

			message("Successfully opened database!");
		}

		private void read_database(){
			message("Reading database data...");

			Statement stmt;
			int rc = 0;
			int col, cols;

			if ((rc = db.prepare_v2 ("SELECT * FROM library;", -1, out stmt, null)) == 1) {
				critical ("SQL error: %d, %s\n", rc, db.errmsg ());
				return;
			}

			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch (rc) {
				case Sqlite.DONE:
					break;
				case Sqlite.ROW:
					message("Found station: " + stmt.column_text(0));
					station_provider.add_station_by_id(int.parse(stmt.column_text(0)));

					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
		}

		private void create_database(){
			message("Create new database...");

			File file = File.new_for_path (database_path);

			try{
				if(!file.query_exists()){
					// create dir
					File dir = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio"));
					dir.make_directory_with_parents();

					// create file
					file.create (FileCreateFlags.NONE);

					open_database();
					init_database();
				}else{
					warning("Database already exists.");
					open_database();
				}
			}catch(Error e){
				critical("Cannot create new database: " + e.message);
			}
		}

		private void init_database(){
			message("Initialize database...");

			string query = """
				CREATE TABLE "library" ('station_id' INTEGER, 'folder_id' INTEGER);
				CREATE TABLE "library_folders" ('folder_id' INTEGER, 'folder_name' TEXT)
				""";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not initialize database: %s\n", db_error_message);
				return ;
			}

			message("Successfully initialized database!");
			open_database();
		}

	}
}
