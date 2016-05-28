using Gtk;
using Gee;

namespace Gradio{

	public class StationsListView : Gtk.ListBox{

		HashMap<int,RadioStation> stations;
		private GLib.Settings settings;

		public StationsListView(){
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			this.expand = true;
			connect_signals();

			reload_view();
		}

		public void set_stations(ref HashMap<int,RadioStation> s){
			stations = s;
			reload_view();
		}

		private void connect_signals(){
			this.row_activated.connect((t,a) => {
				ListItem item = (ListItem)a;
				ActionPopover apop = new ActionPopover(item.station);
				apop.set_relative_to(a);
				apop.set_position(PositionType.BOTTOM);
				apop.show();
			});
		}

		public void reload_view(){
			Util.remove_all_widgets((Gtk.ListBox) this);

			if(stations != null){
				if(!stations.is_empty){
					foreach (var element in stations.entries){
						ListItem box = new ListItem(element.value);
						if(element.value.Available){
							this.add(box);
						}else if(!settings.get_boolean("only-show-working-stations")){
							this.add(box);
						}
					}
				}
			}

		}
	}
}

