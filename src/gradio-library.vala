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
		public static StationModel station_model;

		private Sqlite.Database db;
		private string db_error_message;

		File newdb = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "gradio.db")); // New DB
		File olddb = File.new_for_path (Path.build_filename (Environment.get_user_data_dir (), "gradio", "library.gradio")); // Old DB


		public Library(){
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
			yield read_collections();
			yield read_stations();
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
					station_model.add_item(coll);
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
					string coll_id = stmt.column_text(1);
					string station_id = stmt.column_text(0);

					Util.get_station_by_id.begin(int.parse(station_id), (obj, res) => {
						RadioStation station = Util.get_station_by_id.end(res);

						message("Found station: %s", station.title);

						if(coll_id != "0"){
							Collection coll = (Collection)station_model.get_item_by_id(coll_id);
							coll.add_station(station);

							message("Added %s to collection \"%s\"", station_id, coll.name);
						}else{
							station_model.add_item(station);
						}
					});

					break;
				default:
					printerr ("Error: %d, %s\n", rc, db.errmsg ());
					break;
				}
			} while (rc == Sqlite.ROW);
			message("Imported all stations!");
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
			for(int i = 0; i < collection.station_model.get_n_items(); i++){
				RadioStation station = (RadioStation)collection.station_model.get_item(i);
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

		public bool move_station_to_collection(string collection_id, RadioStation station){
			if(!contains_item(station)){
				warning("Library doesn't contains station \"%s\"", station.title);
				return true;
			}

			Collection collection = get_collection(station);
			if(collection != null) collection.station_model.remove_item(station);

			// Remove station from station_model
			station_model.remove_item(station);

			// Get the actual collection, where the station gets added
			Collection coll = (Collection)station_model.get_item_by_id(collection_id);

			// Add station to collection
			coll.add_station(station);

			if(sql_update_row_library(station.id, collection_id)){
				message("Added station \"%s\" to collection %s", station.title, collection_id);
				return true;
			}else{
				critical("Could not add station \"%s\" to collection %s: %s", station.title, collection_id, db_error_message);
				return false;
			}
		}

		public bool contains_item(Gd.MainBoxItem item){
			for (int i = 0; i < station_model.get_n_items(); i ++) {
      				Gd.MainBoxItem fitem = (Gd.MainBoxItem)station_model.get_item (i);
				if(item.id == fitem.id) return true;
      				if(Util.is_collection_item(int.parse(fitem.id))){
					StationModel m = ((Collection)fitem).station_model;
					for (int i2 = 0; i2 < m.get_n_items(); i2++) {
						Gd.MainBoxItem fitem2 = (Gd.MainBoxItem)m.get_item (i2);
						if (item.id == fitem2.id) return true;
					}
      				}
			}
	    		return false;
		}

		public Collection get_collection(RadioStation station){
			for (int i = 0; i < station_model.get_n_items(); i ++) {
      				Gd.MainBoxItem fstation = (Gd.MainBoxItem)station_model.get_item (i);
				if(station.id == fstation.id) return null;
      				if(Util.is_collection_item(int.parse(fstation.id))){
					StationModel m = ((Collection)fstation).station_model;
					for (int i2 = 0; i2 < m.get_n_items(); i2++) {
						Gd.MainBoxItem fitem2 = (Gd.MainBoxItem)m.get_item (i2);
						if (station.id == fitem2.id) return (Collection)fstation;
					}
      				}
			}
	    		return null;
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
					string address = yield station.get_stream_address();

					dos.put_string("#EXTINF:0,"+station.title+"\n");
					dos.put_string(address+"\n");

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
