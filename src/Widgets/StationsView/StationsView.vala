using Gtk;

namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/stations-view.ui")]
	public class StationsView : Gtk.Box{

		private StationProvider provider;

		public signal void clicked(RadioStation s);

		private bool no_stations = true;
		private bool list_view = false;

		private int results_chunk = 100;
		private int results_loaded = 0;

		private string address;

		[GtkChild]
		private Box LoadMoreBox;
		[GtkChild]
		private Button LoadMoreButton;

		[GtkChild]
		private Box GridViewBox;

		[GtkChild]
		private Box ListViewBox;

		[GtkChild]
		private ScrolledWindow GridScrolledWindow;
		[GtkChild]
		private ScrolledWindow ListScrolledWindow;

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
		private Image HeaderImage;
		[GtkChild]
		private Spinner Spinner;

		private GLib.Settings settings;

		public StationsView(string title = "Items", string image_name = "emblem-documents-symbolic", bool discover_mode = false){
			settings = new GLib.Settings ("de.haecker-felix.gradio");
			provider = new StationProvider();

			HeaderImage.set_from_icon_name(image_name, IconSize.MENU);

			this.expand = true;

			TitleLabel.set_text(title);

			GridViewFlowBox.set_homogeneous(true);
			GridViewFlowBox.halign = Gtk.Align.FILL;
			GridViewFlowBox.valign = Gtk.Align.START;

			if(discover_mode){
				GridViewFlowBox.set_max_children_per_line(1);
				GridViewFlowBox.set_max_children_per_line(1);
				LoadMoreButton.set_visible(false);
				results_chunk = 20;
			}

			connect_signals();
		}

		private void connect_signals(){
			ListViewListBox.row_activated.connect((t,a) => {
				ListItem item = (ListItem)a;
				clicked(item.station);
			});

			GridViewFlowBox.child_activated.connect((t,a) => {
				GridItem item = (GridItem)a;
				clicked(item.station);
			});


			provider.started.connect(() => {
				Idle.add(() => {
					Progress.set_fraction(0.01);
					Progress.set_visible(true);
					LoadMoreButton.set_sensitive(false);
					Spinner.start();
					return false;
				});
			});

			provider.finished.connect(() => {
				Idle.add(() => {
					Progress.set_fraction(1.0);
					Progress.set_visible(false);
					LoadMoreButton.set_sensitive(true);
					Spinner.stop();
					return false;
				});
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
			if(!no_stations){
				StationsStack.set_visible_child_name("list-view");
			}

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

		[GtkCallback]
		private void LoadMoreButton_clicked(Button button){
			load_items_from_address();
		}
	}
}

