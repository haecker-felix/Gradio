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

	public class Library : Object{
		public static StationModel station_model;

		private Sqlite.Database db;
		private string db_error_message;

		File newdb = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "gradio.db")); // New DB
		File olddb = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "library.gradio")); // Old DB

		public bool busy {get;set;}

		public Library(){
			busy = true;
			station_model = new StationModel();

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
			read_database.begin();

			// check for old database (gradio 5 or older)
			if(is_old_database()){
				migrate_old_db.begin();
				return;
			}
		}

		private async void read_database(){
			StationModel collections = yield sql_select_collections();
			foreach(Gd.MainBoxItem item in collections){station_model.add_item(item);}

			StationModel stations = yield sql_select_library();
			foreach(Gd.MainBoxItem item in stations){
				int coll_id = sql_get_collection_id(item.id);

				if(coll_id == 0)
					station_model.add_item(item);
				else{
					Collection coll = (Collection)station_model.get_item_by_id(coll_id.to_string());
					coll.add_station((RadioStation)item);
				}
			}
			busy = false;
		}

		private void open_database(){
			message("Open database...");
			message(newdb.get_path());

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

		public bool add_collection(Collection collection){
			if(contains_item(collection)){
				warning("Library already contains collection \"%s\"", collection.name);
				return true;
			}

			if(sql_insert_row_collection(collection.id, collection.name)){
				station_model.add_item(collection);
				message("Added new collection \"%s\" (%s)", collection.name, collection.id);
				return true;
			}else{
				critical("Could not add collection \"%s\" (%s): %s", collection.name, collection.id, db_error_message);
				return false;
			}
		}

		public bool remove_collection(Collection collection){
			if(!contains_item(collection)){
				warning("Library doesn't contains collection \"%s\"", collection.name);
				return true;
			}

			// Remove all stations in this collection
			foreach(Gd.MainBoxItem item in collection.station_model){
				RadioStation station = (RadioStation)item;
				remove_radio_station(station);
			}

			// Delete collection itself
			if(sql_delete_row_collection(collection.id)){
				station_model.remove_item(collection);
				message("Removed collection \"%s\" (%s)", collection.name, collection.id);
				return true;
			}else{
				critical ("Could not remove collection from database: %s\n", db_error_message);
				return false;
			}
		}

		public bool add_radio_station(RadioStation station){
			if(contains_item(station)){
				warning("Library already contains station \"%s\"", station.title);
				return true;
			}

			if(sql_insert_row_library(station.id, "0")){
				station_model.add_item(station);
				message("Added station \"%s\" (%s) to library", station.title, station.id);
				return true;
			}else{
				critical ("Could not add station to library: %s\n", db_error_message);
				return false;
			}
		}

		public bool remove_radio_station(RadioStation station){
			if(!contains_item(station)){
				warning("Library doesn't contains station \"%s\"", station.title);
				return true;
			}

			if(sql_delete_row_library(station.id)){
				station_model.remove_item(station);
				return true;
			}else{
				critical ("Could not remove station from database: %s\n", db_error_message);
				message("Removed station \"%s\" (%s) from library", station.title, station.id);
				return false;
			}
		}

		public bool station_set_collection_id(RadioStation station, string collection_id){
			if(!contains_item(station)){
				warning("Library doesn't contains station \"%s\"", station.title);
				return true;
			}

			Collection collection = get_collection_by_station(station);
			if(collection != null) collection.station_model.remove_item(station);

			if(collection_id == "0"){ // remove station from a collection
				// Add station to station_model
				if(!station_model.contains_item_with_id(station.id)) station_model.add_item(station);
			}else{ // add station to a collection
				// Remove station from station_model
				station_model.remove_item(station);

				// Get the actual collection, where the station gets added
				Collection coll = (Collection)station_model.get_item_by_id(collection_id);

				// Add station to collection
				coll.add_station(station);
			}


			if(sql_update_row_library(station.id, collection_id)){
				message("Added station \"%s\" to collection %s", station.title, collection_id);
				return true;
			}else{
				critical("Could not add station \"%s\" to collection %s: %s", station.title, collection_id, db_error_message);
				return false;
			}
		}

		public bool contains_item(Gd.MainBoxItem item){
			foreach(Gd.MainBoxItem fitem in station_model){
				if(item.id == fitem.id) return true;
      				if(Util.is_collection_item(int.parse(fitem.id))){
					StationModel m = ((Collection)fitem).station_model;
					foreach(Gd.MainBoxItem fitem2 in m){
						if (item.id == fitem2.id) return true;
					}
      				}
			}
	    		return false;
		}

		public StationModel get_collections(){
			StationModel model = new StationModel();

			// TODO: search in sqlite directly
			foreach(Gd.MainBoxItem item in station_model){
				if(Util.is_collection_item(int.parse(item.id))){
					Collection coll = (Collection) item;
					model.add_item(coll);
				}
			}

			return model;
		}

		public Collection get_collection_by_station(RadioStation station){
			int coll_id = sql_get_collection_id(station.id);
			Collection coll = (Collection)station_model.get_item_by_id(coll_id.to_string());
	    		return coll;
		}

		public void rename_collection(Collection collection, string new_name){
			collection.rename(new_name);
			sql_update_row_collection(collection.id, new_name);
		}

		public void export_database(string path){
			message("Exporting database to: %s", path);
			File dest = File.new_for_path(path);

			try{
				newdb.copy(dest, FileCopyFlags.OVERWRITE, null, null);
			}catch(GLib.Error e){
				critical("Could not export database: %s", e.message);
			}

			message("Successfully exported database!");
		}

		public async void export_as_m3u(string path){
			message("Exporting m3u playlist to: %s", path);

			File file = File.new_for_path (path);
			if(file.query_exists()) file.delete(); // Delete file, if file already exists

			FileIOStream ios = file.create_readwrite(FileCreateFlags.PRIVATE);
			DataOutputStream dos = new DataOutputStream (ios.output_stream);
			dos.put_string ("#EXTM3U\n");

			Statement stmt;
			int rc = 0; int cols;

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
					string station_id = stmt.column_text(0);

					RadioStation station = yield Util.get_station_by_id(int.parse(station_id));
					if (station != null) {
						string address = yield station.get_stream_address();

						dos.put_string("#EXTINF:0,"+station.title+"\n");
						dos.put_string(address+"\n");
					}else{
						warning("Station [%s] not exported: ID not found.", station_id);
					}

					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);

			message("Successfully exported database!");
		}

		public void import_database(string path){
			message("Importing database from path: %s", path);
			File external_db = File.new_for_path(path);

			try{
				station_model.clear();

				newdb.delete();
				external_db.copy(newdb, FileCopyFlags.NONE, null, null);
			}catch(GLib.Error e){
				critical("Could not import database: %s", e.message);
			}

			open_database();
			read_database.begin();
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

		private async StationModel sql_select_collections (){
			StationModel result = new StationModel();
			Statement stmt;
			int rc = 0;
			int cols;

			if ((rc = db.prepare_v2 ("SELECT * FROM collections;", -1, out stmt, null)) == 1) {
				critical ("SQL error: %d, %s\n", rc, db.errmsg ());
				return null;
			}

			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch (rc) {
				case Sqlite.DONE:
					break;
				case Sqlite.ROW:
					Collection coll = new Collection(stmt.column_text(1), stmt.column_text(0));
					result.add_item(coll);
					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
			return result;
		}

		private async StationModel sql_select_library (){
			StationModel result = new StationModel();
			Statement stmt;
			int rc = 0;
			int cols;

			if ((rc = db.prepare_v2 ("SELECT * FROM library;", -1, out stmt, null)) == 1) {
				critical ("SQL error: %d, %s\n", rc, db.errmsg ());
				return null;
			}

			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch (rc) {
				case Sqlite.DONE:
					break;
				case Sqlite.ROW:
					RadioStation station = yield Util.get_station_by_id(int.parse(stmt.column_text(0)));
					result.add_item(station);
					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
			return result;
		}

		// SELECT collection_id FROM library WHERE station_id="0" ;
		private int sql_get_collection_id(string id){
			Statement stmt;
			int rc = 0;
			int cols;

			if ((rc = db.prepare_v2 ("SELECT collection_id FROM library WHERE station_id=\""+id+"\";", -1, out stmt, null)) == 1) {
				critical ("SQL error: %d, %s\n", rc, db.errmsg ());
				return 0;
			}

			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch (rc) {
				case Sqlite.DONE:
					break;
				case Sqlite.ROW:
					int result = int.parse(stmt.column_text(0));
					return result;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
			return 0;
		}

		private bool sql_update_row_collection(string collection_id, string collection_name){
			return execute_query("UPDATE collections SET collection_name = '"+collection_name+"' WHERE collection_id = '"+collection_id+"';");
		}

		private bool sql_insert_row_library(string station_id, string collection_id){
			return execute_query("INSERT INTO library (station_id,collection_id) VALUES ('"+station_id+"', '"+collection_id+"');");
		}

		private bool sql_delete_row_library(string station_id){
			return execute_query("DELETE FROM library WHERE station_id='"+station_id+"';");
		}

		private bool sql_update_row_library(string station_id, string collection_id){
			return execute_query("UPDATE library SET collection_id = '"+collection_id+"' WHERE station_id = '"+station_id+"';");
		}

		private bool sql_insert_row_collection(string collection_id, string collection_name){
			return execute_query("INSERT INTO collections (collection_id,collection_name) VALUES ('"+collection_id+"', '"+collection_name+"');");
		}

		private bool sql_delete_row_collection(string collection_id){
			return execute_query("DELETE FROM collections WHERE collection_id='"+collection_id+"';");
		}

		private bool execute_query (string query){
			message("execute \"%s\"", query);

			int return_code = db.exec (query, null, out db_error_message);
			if (return_code != Sqlite.OK) {
				critical("Could not execute query \"%s\"", query);
				return false;
			}
			return true;
		}
	}
}
