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
		[GtkChild] private Label FinishLabel;

		[GtkChild] private Button CancelButton;
		[GtkChild] private Button DoneButton;
		[GtkChild] private Image FaviconImage;

		private const string address = "http://www.radio-browser.info/webservice/json/add ";

		private Soup.Session soup_session;
		private Json.Parser parser = new Json.Parser();

		private CategoryItems category_items;

		public StationEditorDialog.create(){
			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;

            		Thumbnail _thumbnail = new Thumbnail.for_address(100, FaviconEntry.get_text());
			_thumbnail.updated.connect(() => {
				FaviconImage.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();

			prepare_entry_completion();
		}

		public StationEditorDialog.edit(ref RadioStation station){
			soup_session = new Soup.Session();
            		soup_session.user_agent = "gradio/"+ Config.VERSION;

            		Thumbnail _thumbnail = new Thumbnail.for_address(100, FaviconEntry.get_text());
			_thumbnail.updated.connect(() => {
				FaviconImage.set_from_surface(_thumbnail.surface);
			});
			_thumbnail.show_empty_box();
		}

		private void prepare_entry_completion(){
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
			try{
				parser.load_from_data (data);
				var root = parser.get_root ();

				if(root != null){
					var root_object = root.get_object ();
					if(root_object.get_string_member("ok") ==  "true"){
						finish("Added new radio station");
					}else{
						AnswerLabel.set_text(root_object.get_string_member("message"));
						AnswerBox.set_visible(true);
					}
				}

			}catch(GLib.Error e){
				finish(e.message);
			}
        	}

        	private void finish(string text){
        		FinishLabel.set_text(text);
        		EditorStack.set_visible_child_name("finish");
        		CancelButton.set_visible(false);
        		DoneButton.set_visible(false);
        	}

	}
}		
