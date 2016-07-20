using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/category-tile.ui")]
	public class CategoryTile : Gtk.FlowBoxChild{

		[GtkChild]
		private Label Label;
		[GtkChild]
		private Image Image;

		public string action = "none";

		public CategoryTile(string text, string a, string i){
			Label.set_text(text);
			action = a;

			this.height_request = 44;

			Image.set_from_icon_name (i, IconSize.LARGE_TOOLBAR);
		}

		[GtkCallback]
		private void button_clicked(Button button){
			this.activate();
		}



	}
}
