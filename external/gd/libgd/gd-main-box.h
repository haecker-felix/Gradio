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

#ifndef __GD_MAIN_BOX_H__
#define __GD_MAIN_BOX_H__

#include <gio/gio.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define GD_TYPE_MAIN_BOX gd_main_box_get_type()
G_DECLARE_DERIVABLE_TYPE (GdMainBox, gd_main_box, GD, MAIN_BOX, GtkBin)

typedef enum
{
  GD_MAIN_BOX_ICON,
  GD_MAIN_BOX_LIST
} GdMainBoxType;

struct _GdMainBoxClass
{
  GtkBinClass parent_class;
};

GtkWidget      * gd_main_box_new                      (GdMainBoxType type);
GdMainBoxType    gd_main_box_get_box_type             (GdMainBox *self);
GListModel     * gd_main_box_get_model                (GdMainBox *self);
GList          * gd_main_box_get_selection            (GdMainBox *self);
gboolean         gd_main_box_get_selection_mode       (GdMainBox *self);
gboolean         gd_main_box_get_show_primary_text    (GdMainBox *self);
gboolean         gd_main_box_get_show_secondary_text  (GdMainBox *self);
void             gd_main_box_select_all               (GdMainBox *self);
void             gd_main_box_set_box_type             (GdMainBox *self, GdMainBoxType type);
void             gd_main_box_set_model                (GdMainBox *self, GListModel *model);
void             gd_main_box_set_selection_mode       (GdMainBox *self, gboolean selection_mode);
void             gd_main_box_set_show_primary_text    (GdMainBox *self, gboolean show_primary_text);
void             gd_main_box_set_show_secondary_text  (GdMainBox *self, gboolean show_secondary_text);
void             gd_main_box_unselect_all             (GdMainBox *self);

G_END_DECLS

#endif /* __GD_MAIN_BOX_H__ */
