using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/sidebar-tile.ui")]
	public class SidebarTile : Gtk.Button{

		[GtkChild]
		private Label Label;
		[GtkChild]
		private Image Image;

		public SidebarTile(string text, string img){
			Label.set_text(text);
			Image.set_from_icon_name (img, IconSize.LARGE_TOOLBAR);
		}
	}
}
