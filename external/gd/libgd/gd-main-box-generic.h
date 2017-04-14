/*
 * Copyright (c) 2016, 2017 Red Hat, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by 
 * the Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public 
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License 
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * Author: Debarshi Ray <debarshir@gnome.org>
 *
 */

#ifndef __GD_MAIN_BOX_GENERIC_H__
#define __GD_MAIN_BOX_GENERIC_H__

#include <gio/gio.h>
#include <gtk/gtk.h>

#include "gd-main-box-child.h"

G_BEGIN_DECLS

#define GD_TYPE_MAIN_BOX_GENERIC gd_main_box_generic_get_type()
G_DECLARE_INTERFACE (GdMainBoxGeneric, gd_main_box_generic, GD, MAIN_BOX_GENERIC, GtkWidget)

struct _GdMainBoxGenericInterface
{
  GTypeInterface base_iface;

  /* vtable */
  GdMainBoxChild  * (* get_child_at_index)     (GdMainBoxGeneric *self, gint index);
  const gchar     * (* get_last_selected_id)   (GdMainBoxGeneric *self);
  GListModel      * (* get_model)              (GdMainBoxGeneric *self);
  GList           * (* get_selected_children)  (GdMainBoxGeneric *self);
  void              (* select_all)             (GdMainBoxGeneric *self);
  void              (* select_child)           (GdMainBoxGeneric *self, GdMainBoxChild *child);
  void              (* unselect_all)           (GdMainBoxGeneric *self);
  void              (* unselect_child)         (GdMainBoxGeneric *self, GdMainBoxChild *child);
};

GdMainBoxChild  * gd_main_box_generic_get_child_at_index       (GdMainBoxGeneric *self, gint index);
const gchar     * gd_main_box_generic_get_last_selected_id     (GdMainBoxGeneric *self);
GListModel      * gd_main_box_generic_get_model                (GdMainBoxGeneric *self);
GList           * gd_main_box_generic_get_selected_children    (GdMainBoxGeneric *self);
gboolean          gd_main_box_generic_get_selection_mode       (GdMainBoxGeneric *self);
gboolean          gd_main_box_generic_get_show_primary_text    (GdMainBoxGeneric *self);
gboolean          gd_main_box_generic_get_show_secondary_text  (GdMainBoxGeneric *self);
void              gd_main_box_generic_select_all               (GdMainBoxGeneric *self);
void              gd_main_box_generic_select_child             (GdMainBoxGeneric *self, GdMainBoxChild *child);
void              gd_main_box_generic_set_model                (GdMainBoxGeneric *self, GListModel *model);
void              gd_main_box_generic_set_selection_mode       (GdMainBoxGeneric *self, gboolean selection_mode);
void              gd_main_box_generic_set_show_primary_text    (GdMainBoxGeneric *self, gboolean show_primary_text);
void              gd_main_box_generic_set_show_secondary_text  (GdMainBoxGeneric *self,
                                                                gboolean show_secondary_text);
void              gd_main_box_generic_unselect_all             (GdMainBoxGeneric *self);
void              gd_main_box_generic_unselect_child           (GdMainBoxGeneric *self, GdMainBoxChild *child);

void              gd_main_box_generic_toggle_selection_for_child   (GdMainBoxGeneric  *self,
                                                                    GdMainBoxChild    *child,
                                                                    gboolean           select_range);

G_END_DECLS

#endif /* __GD_MAIN_BOX_GENERIC_H__ */
