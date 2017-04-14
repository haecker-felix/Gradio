/*
 * Copyright (c) 2011 Red Hat, Inc.
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
 * Author: Cosimo Cecchi <cosimoc@redhat.com>
 *
 */

#ifndef __GD_MAIN_VIEW_H__
#define __GD_MAIN_VIEW_H__

#include <glib-object.h>

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define GD_TYPE_MAIN_VIEW gd_main_view_get_type()
G_DECLARE_DERIVABLE_TYPE (GdMainView, gd_main_view, GD, MAIN_VIEW, GtkScrolledWindow)

typedef enum {
  GD_MAIN_VIEW_ICON,
  GD_MAIN_VIEW_LIST
} GdMainViewType;

struct _GdMainViewClass {
  GtkScrolledWindowClass parent_class;
};

GdMainView * gd_main_view_new (GdMainViewType type);
void         gd_main_view_set_view_type (GdMainView *self,
                                         GdMainViewType type);
GdMainViewType gd_main_view_get_view_type (GdMainView *self);

void gd_main_view_set_selection_mode (GdMainView *self,
                                      gboolean selection_mode);
gboolean gd_main_view_get_selection_mode (GdMainView *self);

GList * gd_main_view_get_selection (GdMainView *self);

void gd_main_view_select_all (GdMainView *self);
void gd_main_view_unselect_all (GdMainView *self);

GtkTreeModel * gd_main_view_get_model (GdMainView *self);
void gd_main_view_set_model (GdMainView *self,
                             GtkTreeModel *model);

GtkWidget * gd_main_view_get_generic_view (GdMainView *self);

G_END_DECLS

#endif /* __GD_MAIN_VIEW_H__ */
