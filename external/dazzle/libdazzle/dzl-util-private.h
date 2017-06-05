/* dzl-util-private.h
 *
 * Copyright (C) 2016 Christian Hergert <chergert@redhat.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DZL_UTIL_PRIVATE_H
#define DZL_UTIL_PRIVATE_H

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define dzl_clear_weak_pointer(ptr) \
  (*(ptr) ? (g_object_remove_weak_pointer((GObject*)*(ptr), (gpointer*)ptr),*(ptr)=NULL,1) : 0)

#define dzl_set_weak_pointer(ptr,obj) \
  ((obj!=*(ptr))?(dzl_clear_weak_pointer(ptr),*(ptr)=obj,((obj)?g_object_add_weak_pointer((GObject*)obj,(gpointer*)ptr),NULL:NULL),1):0)

void          dzl_gtk_widget_class_add_css_resource (GtkWidgetClass   *widget_class,
                                                     const gchar      *resource);
void          dzl_gtk_widget_add_class              (GtkWidget        *widget,
                                                     const gchar      *class_name);
gboolean      dzl_gtk_widget_activate_action        (GtkWidget        *widget,
                                                     const gchar      *full_action_name,
                                                     GVariant         *variant);
GVariant     *dzl_gtk_widget_get_action_state       (GtkWidget        *widget,
                                                     const gchar      *action_name);
GActionGroup *dzl_gtk_widget_find_group_for_action  (GtkWidget        *widget,
                                                     const gchar      *action_name);
void          dzl_g_action_name_parse               (const gchar      *action_name,
                                                     gchar           **prefix,
                                                     gchar           **name);
void          dzl_gtk_style_context_get_borders     (GtkStyleContext  *style_context,
                                                     GtkBorder        *borders);
void          dzl_gtk_allocation_subtract_border    (GtkAllocation    *alloc,
                                                     GtkBorder        *border);

G_END_DECLS

#endif /* DZL_UTIL_PRIVATE_H */
