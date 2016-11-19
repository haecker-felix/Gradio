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

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/stations-view.ui")]
	public class StationsView : Gtk.Box{

		private StationProvider provider;

		public signal void clicked(RadioStation s);

		private bool discover_mode = false;
		private bool no_stations = true;
		private bool list_view = false;

		private int results_chunk = 50;
		private int results_loaded = 0;
		private int max_results = 0;

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

		public StationsView(string title = "Items", string image_name = "emblem-documents-symbolic", bool dm = false){
			provider = new StationProvider();
			discover_mode = dm;

			HeaderImage.set_from_icon_name(image_name, IconSize.MENU);

			this.expand = true;

			TitleLabel.set_text(title);

			GridViewFlowBox.set_homogeneous(true);
			GridViewFlowBox.halign = Gtk.Align.FILL;
			GridViewFlowBox.valign = Gtk.Align.START;

			GridViewBox.add(LoadMoreBox);

			if(discover_mode){
				show_grid_view();
				GridViewFlowBox.set_max_children_per_line(1);
				GridViewFlowBox.set_max_children_per_line(1);
				results_chunk = 10;
				disable_load_more();
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

			// ProgressBar
			provider.started.connect(() => {
				Idle.add(() => {
					Progress.set_fraction(0.01);
					Progress.set_visible(true);
					LoadMoreButton.set_visible(false);
					Spinner.start();
					return false;
				});
			});
			provider.finished.connect(() => {
				Idle.add(() => {
					Progress.set_fraction(1.0);
					Progress.set_visible(false);
					LoadMoreButton.set_visible(true);
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

			provider.get_max_items.begin(address, (obj, res) => {
			    	try {
					max_results = provider.get_max_items.end(res);
					if(max_results != 0)
						load_items_from_address();
					else
						StationsStack.set_visible_child_name("no-results");
			    	} catch (ThreadError e) {
					string msg = e.message;
					stderr.printf("Error: Thread:" + msg+ "\n");
			    	}
			});
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

			disable_load_more();

			add_to_view(stations.copy());
		}

		public void add_stations_from_hash_table(HashTable<int,RadioStation> s){
			List<RadioStation> stations = new List<RadioStation>();
			s.foreach ((key, val) => {
				stations.append(val);
			});

			disable_load_more();

			add_to_view(stations.copy());
		}

		private void load_items_from_address(){
			provider.get_radio_stations.begin(address, results_loaded, (results_loaded+results_chunk), (obj, res) => {
			    	try {
					var result = provider.get_radio_stations.end(res);
					results_loaded = results_loaded + results_chunk;
					add_stations_from_list(ref result);

					message("Results_loaded: %i\n", results_loaded);
					message("max_results: %i\n", max_results);
					if(results_loaded <= max_results && !discover_mode){
						enable_load_more();
					}else{
						disable_load_more();
					}
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
			if(!discover_mode){
				if(!no_stations)
				StationsStack.set_visible_child_name("list-view");

				LoadMoreBox.reparent(ListViewBox);

				list_view = true;
			}
		}

		public void show_grid_view(){
			if(!no_stations)
				StationsStack.set_visible_child_name("grid-view");

			LoadMoreBox.reparent(GridViewBox);
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
					}else if(!Settings.hide_broken_stations){
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

		public void set_title(string t){
			TitleLabel.set_text(t);
		}

		private void disable_load_more(){
			LoadMoreBox.set_visible(false);
			Progress.set_visible(false);
			LoadMoreButton.set_visible(false);
		}

		private void enable_load_more(){
			LoadMoreBox.set_visible(true);
			Progress.set_visible(true);
			LoadMoreButton.set_visible(true);
		}

		[GtkCallback]
		private void LoadMoreButton_clicked(Button button){
			load_items_from_address();
		}
	}
}
