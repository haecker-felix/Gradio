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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/station-editor.ui")]
	public class StationEditorDialog : Gtk.Window {

		[GtkChild] private Entry NameEntry;
		[GtkChild] private Entry StreamEntry;
		[GtkChild] private Entry HomepageEntry;
		[GtkChild] private Entry CountryEntry;
		[GtkChild] private Entry StateEntry;
		[GtkChild] private Entry LanguageEntry;
		[GtkChild] private Entry FaviconEntry;

		[GtkChild] private Stack EditorStack;
		[GtkChild] private Box AnswerBox;
		[GtkChild] private Label AnswerLabel;
		[GtkChild] private TextView FinishTextView;

		[GtkChild] private Button CancelButton;
		[GtkChild] private Button DoneButton;
		[GtkChild] private Image FaviconImage;

		[GtkChild] private HeaderBar header;

		private string address;

		private Soup.Session soup_session;
		private Json.Parser parser = new Json.Parser();

		private CategoryItems category_items;

		public StationEditorDialog.create(){
			setup();
			header.set_title("Create radio station");

			address = "http://www.radio-browser.info/webservice/json/add";
		}

		public StationEditorDialog.edit(RadioStation station){
			setup();
			header.set_title("Edit radio station");

			address = " http://www.radio-browser.info/webservice/json/edit/" + station.id;
			NameEntry.set_text(station.title);
			HomepageEntry.set_text(station.homepage);
			CountryEntry.set_text(station.country);
			StateEntry.set_text(station.state);
			LanguageEntry.set_text(station.language);
			FaviconEntry.set_text(station.icon_address);
			StreamEntry.set_text("...");

			station.get_stream_address.begin((obj,res) => {
				string address = station.get_stream_address.end(res);
				StreamEntry.set_text(address);

				message(station.is_broken.to_string());

				if(!station.is_broken)
					StreamEntry.set_sensitive(false);
				else
					StreamEntry.set_sensitive(true);

			});
		}

		private void setup(){
			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;

            		Thumbnail _thumbnail = new Thumbnail.for_address(100, FaviconEntry.get_text());
			_thumbnail.updated.connect(() => {
				FaviconImage.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();

			prepare_entry_completion();
		}

		private void prepare_entry_completion(){
			category_items = new CategoryItems();

			Gtk.EntryCompletion language_completion = new Gtk.EntryCompletion ();
			LanguageEntry.set_completion (language_completion);

			Gtk.EntryCompletion country_completion = new Gtk.EntryCompletion ();
			CountryEntry.set_completion (country_completion);

			Gtk.EntryCompletion state_completion = new Gtk.EntryCompletion ();
			StateEntry.set_completion (state_completion);

			// Language
			Gtk.ListStore language_store = new Gtk.ListStore (1, typeof (string));
			language_completion.set_model (language_store);
			language_completion.set_text_column (0);
			Gtk.TreeIter language_iter;
			language_store.append (out language_iter);
			language_store.set (language_iter, 0, "");
			category_items.languages_model.items_changed.connect((position, removed, added) => {
				if(added == 1){
					language_store.append (out language_iter);
					GenericItem item = (GenericItem)category_items.languages_model.get_item(position);
					language_store.set (language_iter, 0, item.text);
				}
			});

			// Country
			Gtk.ListStore country_store = new Gtk.ListStore (1, typeof (string));
			country_completion.set_model (country_store);
			country_completion.set_text_column (0);
			Gtk.TreeIter country_iter;
			country_store.append (out country_iter);
			country_store.set (country_iter, 0, "");
			category_items.countries_model.items_changed.connect((position, removed, added) => {
				if(added == 1){
					country_store.append (out country_iter);
					GenericItem item = (GenericItem)category_items.countries_model.get_item(position);
					country_store.set (country_iter, 0, item.text);
				}
			});


			// State
			Gtk.ListStore state_store = new Gtk.ListStore (1, typeof (string));
			state_completion.set_model (state_store);
			state_completion.set_text_column (0);
			Gtk.TreeIter state_iter;
			state_store.append (out state_iter);
			state_store.set (state_iter, 0, "");
			category_items.states_model.items_changed.connect((position, removed, added) => {
				if(added == 1){
					state_store.append (out state_iter);
					GenericItem item = (GenericItem)category_items.states_model.get_item(position);
					state_store.set (state_iter, 0, item.text);
				}
			});


		}

		[GtkCallback]
		private void CancelButton_clicked(){
			this.destroy();
		}

		[GtkCallback]
		private void DoneButton_clicked(){
			if(NameEntry.get_text() == "" || StreamEntry.get_text() == ""){
				AnswerLabel.set_text("\"Name\" and \"Stream\" information is required.");
				EditorStack.set_visible_child_name("edit");
				AnswerBox.set_visible(true);
				return;
			}

			HashTable<string, string> table = new HashTable<string, string> (str_hash, str_equal);

			table.insert("name", NameEntry.get_text());
			table.insert("url", StreamEntry.get_text());
			table.insert("homepage", HomepageEntry.get_text());
			table.insert("favicon", FaviconEntry.get_text());
			table.insert("country", CountryEntry.get_text());
			table.insert("state", StateEntry.get_text());
			table.insert("language", LanguageEntry.get_text());

			Soup.Message msg = Soup.Form.request_new_from_hash("POST", address, table);

			EditorStack.set_visible_child_name("loading");
			soup_session.queue_message (msg, (sess, mess) => {
				parse_result.begin((string) mess.response_body.data);
			});
		}

		[GtkCallback]
		private void FaviconEntry_changed(){
			Thumbnail _thumbnail = new Thumbnail.for_address(100, FaviconEntry.get_text());
			_thumbnail.updated.connect(() => {
				FaviconImage.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();
		}

		private async void parse_result(string data){
			message("Result: " + data);

			try{
				parser.load_from_data (data);
				var root = parser.get_root ();

				if(root != null){
					var root_object = root.get_object ();
					finish(root_object.get_string_member("message"));
				}

			}catch(GLib.Error e){
				finish(e.message);
			}
        	}

        	private void finish(string text){
        		FinishTextView.buffer.text = text;
        		EditorStack.set_visible_child_name("finish");
        		CancelButton.set_visible(false);
        		DoneButton.set_visible(false);
        	}

	}
}		
