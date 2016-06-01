using Gtk;
using Gee;

namespace Gradio{

	public class StationsGridView : Gtk.FlowBox{

		HashMap<int,RadioStation> stations;
		private GLib.Settings settings;

		public StationsGridView(){
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			this.expand = true;
			this.set_homogeneous(true);
			this.valign = Gtk.Align.START;
			//this.halign = Gtk.Align.START;
			connect_signals();

			reload_view();
		}

		public void set_stations(ref HashMap<int,RadioStation> s){
			stations = s;
			reload_view();
		}

		private void connect_signals(){
			this.child_activated.connect((t,a) => {
				GridItem item = (GridItem)a;
				ActionPopover apop = new ActionPopover(item.station);
				apop.set_relative_to(a);
				apop.set_position(PositionType.RIGHT);
				apop.show();
			});
		}

		public void reload_view(){
			Util.remove_all_items_from_flow_box((Gtk.FlowBox) this);

			if(stations != null){
				if(!stations.is_empty){
					foreach (var element in stations.entries){
						GridItem box = new GridItem(element.value);
						if(!(element.value.Broken)){
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

