using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/stations-view.ui")]
	public class StationsView : Gtk.Box{

		private StationProvider provider;

		private bool no_stations = true;
		private bool list_view = false;

		private int results_chunk = -1;
		private int results_loaded = 0;

		private string address;

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
		private ProgressBar Progress;

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
		[GtkChild]
		private Spinner Spinner;

		private GLib.Settings settings;

		public StationsView(string title, bool scrollable, string image_name = "emblem-documents-symbolic", int max = -1){
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			provider = new StationProvider();

			if(max == -1)
				results_chunk = 50;
			else
			results_chunk = max;

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
				Progress.set_visible(true);
				Idle.add(() => { Progress.set_fraction(0.01); return false;});
				Spinner.start();
			});

			provider.finished.connect(() => {
				Idle.add(() => { Progress.set_fraction(1.0); return false;});
				Progress.set_visible(false);

				//TODO: set correct grid/list
				Spinner.stop();
			});

			provider.progress.connect((t) => {
				Idle.add(() => { Progress.set_fraction(t); return false;});
			});

		}

		public void set_stations_from_address(string a){
			reset();
			address = a;

			load_items_from_address();
		}

		public void set_stations_from_list(List<RadioStation> s){
			reset();

			add_to_view(s.copy());
		}

		public void add_stations_from_list(ref List<RadioStation> s){
			add_to_view(s.copy());
		}

		public void set_stations_from_hash_table(HashTable<int,RadioStation> s){
			reset();

			List<RadioStation> stations = new List<RadioStation>();
			s.foreach ((key, val) => {
				stations.append(val);
			});

			add_to_view(stations.copy());
		}

		public void add_stations_from_hash_table(HashTable<int,RadioStation> s){
			List<RadioStation> stations = new List<RadioStation>();
			s.foreach ((key, val) => {
				stations.append(val);
			});

			add_to_view(stations.copy());
		}

		private void load_items_from_address(){
			provider.get_radio_stations.begin(address, results_loaded, (results_loaded+results_chunk), (obj, res) => {
			    	try {
					var result = provider.get_radio_stations.end(res);
					results_loaded = results_loaded + results_chunk;
					add_stations_from_list(ref result);
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

		private void reset (){
			reset_data();
			reset_view();
		}

		private void reset_data(){
			results_loaded = 0;
		}

		private void reset_view(){
			Util.remove_all_items_from_flow_box((Gtk.FlowBox) GridViewFlowBox);
			Util.remove_all_items_from_list_box((Gtk.ListBox) ListViewListBox);
		}

		[GtkCallback]
		private void ListScrolled_edge_reached(PositionType t){
			if(t == PositionType.BOTTOM)
				load_items_from_address();
		}

		[GtkCallback]
		private void GridScrolled_edge_reached(PositionType t){
			if(t == PositionType.BOTTOM)
				load_items_from_address();
		}

		public void add_to_view(List<RadioStation> new_stations){
			if((int)new_stations.length != 0){
				no_stations = false;

				new_stations.foreach ((val) => {
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

