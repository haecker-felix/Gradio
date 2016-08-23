using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/stations-view.ui")]
	public class StationsView : Gtk.Box{

		HashTable<int,RadioStation> stations;

		private StationProvider provider;

		private bool no_stations = true;
		private bool list_view = false;

		private int max_results = -1;

		[GtkChild]
		private FlowBox GridViewFlowBox;
		[GtkChild]
		private ListBox ListViewListBox;
		[GtkChild]
		private Stack StationsStack;
		[GtkChild]
		private Label TitleLabel;
		[GtkChild]
		private Box ExtraItemBox;

		[GtkChild]
		private Viewport GridScrolledViewport;
		[GtkChild]
		private Viewport ListScrolledViewport;

		[GtkChild]
		private Box GridNormal;
		[GtkChild]
		private Box ListNormal;

		[GtkChild]
		private Stack GridViewStack;
		[GtkChild]
		private Stack ListViewStack;
		[GtkChild]
		private Image HeaderImage;

		private GLib.Settings settings;

		public StationsView(string title, bool scrollable, string image_name = "emblem-documents-symbolic", int max = -1){
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			provider = new StationProvider();

			if(max == -1)
				max_results = 200;
			else
			max_results = max;

			HeaderImage.set_from_icon_name(image_name, IconSize.MENU);

			this.expand = true;

			if(scrollable){
				GridScrolledViewport.add(GridViewFlowBox);
				ListScrolledViewport.add(ListViewListBox);
				GridViewStack.set_visible_child_name("grid-scrolled");
				ListViewStack.set_visible_child_name("list-scrolled");
			}else{
				GridNormal.add(GridViewFlowBox);
				ListNormal.add(ListViewListBox);
				GridViewStack.set_visible_child_name("grid-normal");
				ListViewStack.set_visible_child_name("list-normal");
			}

			TitleLabel.set_text(title);

			GridViewFlowBox.set_homogeneous(true);
			GridViewFlowBox.halign = Gtk.Align.FILL;
			GridViewFlowBox.valign = Gtk.Align.START;
			GridViewFlowBox.set_min_children_per_line(2);

			connect_signals();
			reload_view();
		}

		private void connect_signals(){
			ListViewListBox.row_activated.connect((t,a) => {
				ListItem item = (ListItem)a;
				ActionPopover apop = new ActionPopover(item.station);
				apop.set_relative_to(a);
				apop.set_position(PositionType.BOTTOM);
				apop.show();
			});


			GridViewFlowBox.child_activated.connect((t,a) => {
				GridItem item = (GridItem)a;
				ActionPopover apop = new ActionPopover(item.station);
				apop.set_relative_to(a);
				apop.set_position(PositionType.BOTTOM);
				apop.show();
			});

			provider.started.connect(() => {
				StationsStack.set_visible_child_name("loading");
			});

			provider.finished.connect(() => {
				//TODO: set correct grid/list
				StationsStack.set_visible_child_name("grid-view");
			});

		}

		public void set_stations_from_list(HashTable<int,RadioStation> s){
			if(s != null)
				stations = s;
			reload_view();
		}

		public void set_stations_from_address(string address){
			provider.get_radio_stations.begin(address, max_results, (obj, res) => {
			    	try {
					var result = provider.get_radio_stations.end(res);
					set_stations_from_list(result);
			    	} catch (ThreadError e) {
					string msg = e.message;
					stderr.printf("Error: Thread:" + msg+ "\n");
			    	}
        		});
		}

		public void set_extra_item(Gtk.Widget w){
			ExtraItemBox.add(w);
		}

		public void show_list_view(){
			if(!no_stations)
				StationsStack.set_visible_child_name("list-view");
			list_view = true;
		}

		public void show_grid_view(){
			if(!no_stations)
				StationsStack.set_visible_child_name("grid-view");
			list_view = false;
		}

		public void reload_view(){
			Util.remove_all_items_from_flow_box((Gtk.FlowBox) GridViewFlowBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) ListViewListBox);

			if(stations != null){
				if(stations.length != 0){
					no_stations = false;
					stations.foreach ((key, val) => {
						GridItem grid_box = new GridItem(val);
						ListItem list_box = new ListItem(val);
						if(!(val.Broken)){
							GridViewFlowBox.add(grid_box);
							ListViewListBox.add(list_box);
						}else if(!settings.get_boolean("only-show-working-stations")){
							GridViewFlowBox.add(grid_box);
							ListViewListBox.add(list_box);
						}
					});
					if(list_view)
						show_list_view();
					else
						show_grid_view();

				}else{
					no_stations = true;
					StationsStack.set_visible_child_name("no-results");
				}
			}

		}
	}
}

