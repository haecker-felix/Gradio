using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/categories-row.ui")]
	public class CategoriesRow : Gtk.ListBoxRow{

		[GtkChild]
		private Label Label;
		[GtkChild]
		private Image Image;

		public string action = "none";

		public CategoriesRow(string text, string a){
			Label.set_text(text);
			action = a;

		}



	}
}
