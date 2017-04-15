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

namespace Gradio {

	public class Notification : Gd.Notification {

		private Gtk.Box m_box;
		private Gtk.Button m_Button;
		public signal void action();

		public Notification(string message_text, int timeout = 5){
			this.set_timeout(timeout);
			this.set_show_close_button(true);
			this.add(new Label(message_text));

			connect_signals();
		}

		public Notification.with_button(string message_text, string button_text, int timeout = 5){
			this.set_timeout(timeout);

			m_Button = new Gtk.Button.with_label(button_text);

			m_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
			m_box.pack_start(new Gtk.Label(message_text));
			m_box.pack_start(m_Button);
			this.add(m_box);

			connect_signals();
		}


		private void connect_signals()
		{
			this.unrealize.connect(() => {
				dismissed();
			});

			m_Button.clicked.connect(() => {
				action();
			});
		}

	}
}
