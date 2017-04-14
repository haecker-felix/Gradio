/*
 * Copyright (c) 2011, 2012 Red Hat, Inc.
 *
 * Gnome Documents is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * Gnome Documents is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with Gnome Documents; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * Author: Cosimo Cecchi <cosimoc@redhat.com>
 *
 */

#include "gd-entry-focus-hack.h"

/* taken from gtk/gtktreeview.c */
static void
send_focus_change (GtkWidget *widget,
                   GdkDevice *device,
		   gboolean   in)
{
  GdkDeviceManager *device_manager;
  GList *devices, *d;

  device_manager = gdk_display_get_device_manager (gtk_widget_get_display (widget));
  devices = gdk_device_manager_list_devices (device_manager, GDK_DEVICE_TYPE_MASTER);
  devices = g_list_concat (devices, gdk_device_manager_list_devices (device_manager, GDK_DEVICE_TYPE_SLAVE));
  devices = g_list_concat (devices, gdk_device_manager_list_devices (device_manager, GDK_DEVICE_TYPE_FLOATING));

  for (d = devices; d; d = d->next)
    {
      GdkDevice *dev = d->data;
      GdkEvent *fevent;
      GdkWindow *window;

      if (gdk_device_get_source (dev) != GDK_SOURCE_KEYBOARD)
        continue;

      window = gtk_widget_get_window (widget);
      if (!window)
        continue;

      /* Skip non-master keyboards that haven't
       * selected for events from this window
       */
      if (gdk_device_get_device_type (dev) != GDK_DEVICE_TYPE_MASTER &&
          !gdk_window_get_device_events (window, dev))
        continue;

      fevent = gdk_event_new (GDK_FOCUS_CHANGE);

      fevent->focus_change.type = GDK_FOCUS_CHANGE;
      fevent->focus_change.window = g_object_ref (window);
      fevent->focus_change.in = in;
      gdk_event_set_device (fevent, device);

      gtk_widget_send_focus_change (widget, fevent);

      gdk_event_free (fevent);
    }

  g_list_free (devices);
}

void
gd_entry_focus_hack (GtkWidget *entry,
                     GdkDevice *device)
{
  GtkEntryClass *entry_class;
  GtkWidgetClass *entry_parent_class;

  /* Grab focus will select all the text.  We don't want that to happen, so we
   * call the parent instance and bypass the selection change.  This is probably
   * really non-kosher. */
  entry_class = g_type_class_peek (GTK_TYPE_ENTRY);
  entry_parent_class = g_type_class_peek_parent (entry_class);
  (entry_parent_class->grab_focus) (entry);

  /* send focus-in event */
  send_focus_change (entry, device, TRUE);
}
