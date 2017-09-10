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

		public static StationModel station_model;
		public static CollectionModel collection_model;

		private Sqlite.Database db;
		private string db_error_message;

		File newdb = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "gradio.db")); // New DB
		File olddb = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "library.gradio")); // Old DB


		public Library(){
			station_model = new StationModel();
			collection_model = new CollectionModel();

			// check for new database
			if(!database_exists()){
				create_database();
				open_database();
				init_database();
			}else{
				open_database();
			}

			// read database data
			message("Successfully opened database! Reading database data...");
			read_collections.begin();
			read_stations.begin();

			// check for old database (gradio 5 or older)
			if(is_old_database()){
				migrate_old_db.begin();
				return;
			}
		}

		private void open_database(){
			message("Open database...");

			int return_code = Sqlite.Database.open (newdb.get_path(), out db);
			if (return_code!= Sqlite.OK) {
				critical ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
				return;
			}
		}

		private void create_database(){
			message("Create new database...");
			File dir = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio"));

			try{
				if(!newdb.query_exists()){
					if(!dir.query_exists()){
						dir.make_directory_with_parents();
					}
					newdb.create (FileCreateFlags.NONE);

				}else{
					warning("Database already exists.");
				}
			}catch(Error e){
				critical("Cannot create new database: " + e.message);
			}
		}

		private void init_database(){
			message("Initialize database...");

			string query = """
				CREATE TABLE "library" ('station_id' INTEGER, 'collection_id' INTEGER);
				CREATE TABLE "collections" ('collection_id' INTEGER, 'collection_name' TEXT)
				""";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not initialize database: %s\n", db_error_message);
				return ;
			}

			message("Successfully initialized database!");
		}

		private async void read_collections(){
			message("Importing collections...");
			Statement stmt;
			int rc = 0;
			int cols;

			if ((rc = db.prepare_v2 ("SELECT * FROM collections;", -1, out stmt, null)) == 1) {
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
					message("Found collection: %s %s", stmt.column_text(0), stmt.column_text(1));
					Collection coll = new Collection(stmt.column_text(1), stmt.column_text(0));
					collection_model.add_collection(coll);
					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
			message("Imported all collections!");
		}

		private async void read_stations(){
			message("Importing stations...");
			Statement stmt;
			int rc = 0;
			int cols;

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
					RadioStation station = yield Util.get_station_by_id(int.parse(stmt.column_text(0)));

					message("Found station: %s", station.title);
					station_model.add_station(station);

					if(stmt.column_text(1) != "0"){
						Collection coll = collection_model.get_collection_by_id(stmt.column_text(1));
						coll.add_station(station);

						message("Added %s to collection \"%s\"", stmt.column_text(0), coll.name);
					}

					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
			message("Imported all stations!");
		}

		public bool add_station_to_collection(string collection_id, RadioStation station){
			// Station must be in the library
			if((!station_model.contains_station(station)))
				return false;

			// Remove the station from the previous collection (a station can be only in one collection)
			Statement stmt; int rc = 0; int cols;
			if ((rc = db.prepare_v2 ("SELECT collection_id from library WHERE station_id = '"+station.id+"';", -1, out stmt, null)) == 1) {
				critical ("SQL error: %d, %s\n", rc, db.errmsg ());
				return false;
			}
			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch (rc) {
				case Sqlite.DONE:
					break;
				case Sqlite.ROW:
					if(stmt.column_text(0) != "0") // if text == 0, there is no previous collection, so do nothing.
						remove_station_from_collection(stmt.column_text(0), station); break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);

			// Get the actual collection, where the station gets added
			Collection coll = (Collection)collection_model.get_collection_by_id(collection_id);

			// Add the station to the new collection (if the collection exists)
			if(coll != null){
				coll.add_station(station);

				string query = "UPDATE library SET collection_id = '"+collection_id+"' WHERE station_id = "+station.id+";";

				int return_code = db.exec (query, null, out db_error_message);
				if (return_code != Sqlite.OK) {
					critical("Could not add station \"%s\" to collection %s: %s", station.title, collection_id, db_error_message);
					return false;
				}else{
					message("Added station \"%s\" to collection %s", station.title, collection_id);
					return true;
				}
			}else{
				warning("Adding station to collection %s: Collection not found.", collection_id);
				return false;
			}
		}

		public bool remove_station_from_collection(string collection_id, RadioStation station){
			// Set the collection_id to 0 for the specific station
			string query = "UPDATE library SET collection_id = '0' WHERE station_id = "+station.id+";";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical("Could not remove station \"%s\" from collection %s: %s", station.title, collection_id, db_error_message);
				return false;
			}

			// Remove the station from the collection itself
			Collection coll = collection_model.get_collection_by_id(collection_id);
			coll.remove_station(station);

			message("Removed station \"%s\" from collection %s", station.title, collection_id);
			return true;
		}

		public bool add_new_collection(Collection collection){
			if(collection_model.contains_collection(collection) || collection == null)
				return true;

			string query = "INSERT INTO collections (collection_id,collection_name) VALUES ('"+collection.id+"', '"+collection.name+"');";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical("Could not add collection \"%s\" (%s): %s", collection.name, collection.id, db_error_message);
				return false;
			}else{
				collection_model.add_collection(collection);
				message("Added new collection \"%s\" (%s)", collection.name, collection.id);
				return true;
			}
		}

		public bool remove_collection(Collection collection){
			// Remove the collection_id from the stations
			string query = "UPDATE library SET collection_id = '0' WHERE collection_id = "+collection.id+";";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not update collection id: %s\n", db_error_message);
				return false;
			}

			// Delete the collection itself
			query = "DELETE FROM collections WHERE collection_id=" + collection.id;

			return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
			 	critical ("Could not remove collection from database: %s\n", db_error_message);
			 	return false;
			}else{
			 	Idle.add(() => {
			 		collection_model.remove_collection(collection);
					return false;
			 	});
			}

			message("Removed collection \"%s\" (%s)", collection.name, collection.id);
			return true;
		}

		public bool add_radio_station(RadioStation station){
			if(station_model.contains_station(station) || station == null)
				return true;

			string query = "INSERT INTO library (station_id,collection_id) VALUES ("+station.id+", '0');";

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not add station to library: %s\n", db_error_message);
				return false;
			}else{
				Idle.add(() => {
					station_model.add_station(station);
					return false;
				});
				message("Added station \"%s\" (%s) to library", station.title, station.id);
				return true;
			}
		}

		public bool remove_radio_station(RadioStation station){
			if(!station_model.contains_station(station))
				return true;

			// Remove the station from the collection
			Statement stmt; int rc = 0; int cols;
			if ((rc = db.prepare_v2 ("SELECT collection_id from library WHERE station_id = '"+station.id+"';", -1, out stmt, null)) == 1) {
				critical ("SQL error: %d, %s\n", rc, db.errmsg ());
				return false;
			}
			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch (rc) {
				case Sqlite.DONE:
					break;
				case Sqlite.ROW:
					Collection previous_coll = collection_model.get_collection_by_id(stmt.column_text(0));
					previous_coll.remove_station(station);
					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);


			// Remove the station itself
			string query = "DELETE FROM library WHERE station_id=" + station.id;

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical ("Could not remove station from database: %s\n", db_error_message);
				return false;
			}else{
				Idle.add(() => {
					station_model.remove_station(station);
					removed_radio_station(station);
					return false;
				});

				message("Removed station \"%s\" (%s) from library", station.title, station.id);
				return true;
			}
		}

		public void export_database(string path){
			message("Exporting database to: %s", path);
			File dest = File.new_for_path(path);

			try{
				newdb.copy(dest, FileCopyFlags.NONE, null, null);
			}catch(GLib.Error e){
				critical("Could not export database: %s", e.message);
			}

			message("Successfully exported database!");
		}

		public void import_database(string path){
			message("Importing database from path: %s", path);
			File external_db = File.new_for_path(path);

			try{
				station_model.clear();
				collection_model.clear();

				newdb.delete();
				external_db.copy(newdb, FileCopyFlags.NONE, null, null);
			}catch(GLib.Error e){
				critical("Could not import database: %s", e.message);
			}

			message("Successfully imported database!");
		}

		private async void migrate_old_db(){
			File file = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "library.gradio"));

			if(file.query_exists()){
				message("Old database found, which is going to be converted into the new sqlite3 format, to use gradio properly.");
			}else{
				return;
			}

			try{
				if(file.query_exists ()){
					DataInputStream dis = null;
					try{dis = new DataInputStream (file.read());}catch(Error e){critical("Could not migrate old database: %s", e.message);}
					string line;

					while ((line = dis.read_line (null)) != null) {
						RadioStation station = yield Util.get_station_by_id(int.parse(line));

						if(station != null){
							add_radio_station(station);
						}
					}

					try{
						yield file.delete_async();
					}catch (Error e){
						critical("Could not delete old database: " + e.message);
					}
				}
			}catch(GLib.IOError error){
				critical("Could not migrate old database: %s", error.message);
			}


		}

		private bool is_old_database (){
			if(olddb.query_exists()){
				return true;
			}
			return false;
		}

		private bool database_exists (){
			if(newdb.query_exists()){
				return true;
			}
			return false;
		}


	}
}
