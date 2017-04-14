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

#include "gd-main-list-view.h"
#include "gd-main-view-generic.h"
#include "gd-two-lines-renderer.h"

#include <cairo-gobject.h>
#include <glib/gi18n.h>

struct _GdMainListViewPrivate {
  GtkTreeViewColumn *tree_col;
  GtkCellRenderer *pixbuf_cell;
  GtkCellRenderer *selection_cell;
  GtkCellRenderer *text_cell;

  gboolean selection_mode;
};

static void gd_main_view_generic_iface_init (GdMainViewGenericIface *iface);
G_DEFINE_TYPE_WITH_CODE (GdMainListView, gd_main_list_view, GTK_TYPE_TREE_VIEW,
                         G_IMPLEMENT_INTERFACE (GD_TYPE_MAIN_VIEW_GENERIC,
                                                gd_main_view_generic_iface_init))

static gboolean gd_main_list_view_draw (GtkWidget *widget,
					cairo_t   *cr);

static GtkTreePath*
get_source_row (GdkDragContext *context)
{
  GtkTreeRowReference *ref =
    g_object_get_data (G_OBJECT (context), "gtk-tree-view-source-row");

  if (ref)
    return gtk_tree_row_reference_get_path (ref);
  else
    return NULL;
}

static void
set_attributes_from_model (GdMainListView *self)
{
  GtkTreeModel *model = gtk_tree_view_get_model (GTK_TREE_VIEW (self));
  GType icon_gtype;

  if (!model)
    return;

  gtk_tree_view_column_clear_attributes (self->priv->tree_col, self->priv->pixbuf_cell);
  gtk_tree_view_column_clear_attributes (self->priv->tree_col, self->priv->selection_cell);
  gtk_tree_view_column_clear_attributes (self->priv->tree_col, self->priv->text_cell);


  gtk_tree_view_column_add_attribute (self->priv->tree_col, self->priv->selection_cell,
                                      "active", GD_MAIN_COLUMN_SELECTED);

  icon_gtype = gtk_tree_model_get_column_type (model, GD_MAIN_COLUMN_ICON);
  if (icon_gtype == GDK_TYPE_PIXBUF)
    gtk_tree_view_column_add_attribute (self->priv->tree_col, self->priv->pixbuf_cell,
					"pixbuf", GD_MAIN_COLUMN_ICON);
  else if (icon_gtype == CAIRO_GOBJECT_TYPE_SURFACE)
    gtk_tree_view_column_add_attribute (self->priv->tree_col, self->priv->pixbuf_cell,
					"surface", GD_MAIN_COLUMN_ICON);
  else
    g_assert_not_reached ();

  gtk_tree_view_column_add_attribute (self->priv->tree_col, self->priv->text_cell,
                                      "text", GD_MAIN_COLUMN_PRIMARY_TEXT);
  gtk_tree_view_column_add_attribute (self->priv->tree_col, self->priv->text_cell,
                                      "line-two", GD_MAIN_COLUMN_SECONDARY_TEXT);
}

static void
gd_main_list_view_drag_data_get (GtkWidget *widget,
                                 GdkDragContext *drag_context,
                                 GtkSelectionData *data,
                                 guint info,
                                 guint time)
{
  GdMainListView *self = GD_MAIN_LIST_VIEW (widget);
  GtkTreeModel *model = gtk_tree_view_get_model (GTK_TREE_VIEW (self));

  if (info != 0)
    return;

  _gd_main_view_generic_dnd_common (model,
                                    self->priv->selection_mode,
                                    get_source_row (drag_context), data);

  GTK_WIDGET_CLASS (gd_main_list_view_parent_class)->drag_data_get (widget, drag_context,
                                                                    data, info, time);
}

static void
gd_main_list_view_constructed (GObject *obj)
{
  GdMainListView *self = GD_MAIN_LIST_VIEW (obj);
  GtkCellRenderer *cell;
  GtkTreeSelection *selection;
  const GtkTargetEntry targets[] = {
    { "text/uri-list", GTK_TARGET_OTHER_APP, 0 }
  };

  G_OBJECT_CLASS (gd_main_list_view_parent_class)->constructed (obj);

  gtk_widget_set_hexpand (GTK_WIDGET (self), TRUE);
  gtk_widget_set_vexpand (GTK_WIDGET (self), TRUE);

  g_object_set (self,
                "headers-visible", FALSE,
                "enable-search", FALSE,
                NULL);

  selection = gtk_tree_view_get_selection (GTK_TREE_VIEW (self));
  gtk_tree_selection_set_mode (selection, GTK_SELECTION_NONE);

  self->priv->tree_col = gtk_tree_view_column_new ();
  gtk_tree_view_append_column (GTK_TREE_VIEW (self), self->priv->tree_col);

  self->priv->selection_cell = cell = gtk_cell_renderer_toggle_new ();
  g_object_set (cell, 
                "visible", FALSE,
                "xpad", 12,
                "xalign", 1.0,
                NULL);
  gtk_tree_view_column_pack_start (self->priv->tree_col, cell, FALSE);

  self->priv->pixbuf_cell = cell = gtk_cell_renderer_pixbuf_new ();
  g_object_set (cell,
                "xalign", 0.5,
                "yalign", 0.5,
                "xpad", 12,
                "ypad", 2,
                NULL);
  gtk_tree_view_column_pack_start (self->priv->tree_col, cell, FALSE);

  self->priv->text_cell = cell = gd_two_lines_renderer_new ();
  g_object_set (cell,
                "xalign", 0.0,
                "wrap-mode", PANGO_WRAP_WORD_CHAR,
                "xpad", 12,
                "text-lines", 2,
                NULL);
  gtk_tree_view_column_pack_start (self->priv->tree_col, cell, TRUE);

  set_attributes_from_model (self);

  gtk_tree_view_enable_model_drag_source (GTK_TREE_VIEW (self),
                                          GDK_BUTTON1_MASK,
                                          targets, 1,
                                          GDK_ACTION_COPY);
}

static void
gd_main_list_view_class_init (GdMainListViewClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);
  GtkWidgetClass *wclass = GTK_WIDGET_CLASS (klass);
  GtkBindingSet *binding_set;
  GdkModifierType activate_modifiers[] = { GDK_SHIFT_MASK, GDK_CONTROL_MASK, GDK_SHIFT_MASK | GDK_CONTROL_MASK };
  guint i;

  binding_set = gtk_binding_set_by_class (klass);

  oclass->constructed = gd_main_list_view_constructed;
  wclass->drag_data_get = gd_main_list_view_drag_data_get;
  wclass->draw = gd_main_list_view_draw;

  g_type_class_add_private (klass, sizeof (GdMainListViewPrivate));

  for (i = 0; i < G_N_ELEMENTS (activate_modifiers); i++)
    {
      gtk_binding_entry_add_signal (binding_set, GDK_KEY_space, activate_modifiers[i],
				    "select-cursor-row", 1,
				    G_TYPE_BOOLEAN, TRUE);
      gtk_binding_entry_add_signal (binding_set, GDK_KEY_KP_Space, activate_modifiers[i],
				    "select-cursor-row", 1,
				    G_TYPE_BOOLEAN, TRUE);
      gtk_binding_entry_add_signal (binding_set, GDK_KEY_Return, activate_modifiers[i],
				    "select-cursor-row", 1,
				    G_TYPE_BOOLEAN, TRUE);
      gtk_binding_entry_add_signal (binding_set, GDK_KEY_ISO_Enter, activate_modifiers[i],
				    "select-cursor-row", 1,
				    G_TYPE_BOOLEAN, TRUE);
      gtk_binding_entry_add_signal (binding_set, GDK_KEY_KP_Enter, activate_modifiers[i],
				    "select-cursor-row", 1,
				    G_TYPE_BOOLEAN, TRUE);
    }

}

static void
gd_main_list_view_init (GdMainListView *self)
{
  self->priv = G_TYPE_INSTANCE_GET_PRIVATE (self, GD_TYPE_MAIN_LIST_VIEW, GdMainListViewPrivate);

  g_signal_connect (self, "notify::model",
		    G_CALLBACK (set_attributes_from_model), NULL);
}

static GtkTreePath *
gd_main_list_view_get_path_at_pos (GdMainViewGeneric *mv,
                                   gint x,
                                   gint y)
{
  GtkTreePath *path = NULL;

  gtk_tree_view_get_path_at_pos (GTK_TREE_VIEW (mv), x, y, &path,
                                 NULL, NULL, NULL);

  return path;
}

static void
gd_main_list_view_set_selection_mode (GdMainViewGeneric *mv,
                                      gboolean selection_mode)
{
  GdMainListView *self = GD_MAIN_LIST_VIEW (mv);

  self->priv->selection_mode = selection_mode;

  g_object_set (self->priv->selection_cell,
                "visible", selection_mode,
                NULL);
  gtk_tree_view_column_queue_resize (self->priv->tree_col);
}

static gboolean
gd_main_list_view_draw (GtkWidget *widget,
			cairo_t   *cr)
{
  GdMainListView *self = GD_MAIN_LIST_VIEW (widget);
  GtkStyleContext *context;
  GdkRectangle lines_rect;
  GdkRectangle rect;
  GtkTreePath *path;
  GtkTreePath *rubberband_start, *rubberband_end;

  GTK_WIDGET_CLASS (gd_main_list_view_parent_class)->draw (widget, cr);

  _gd_main_view_generic_get_rubberband_range (GD_MAIN_VIEW_GENERIC (self),
					      &rubberband_start, &rubberband_end);

  if (rubberband_start)
    {
      context = gtk_widget_get_style_context (widget);

      gtk_style_context_save (context);
      gtk_style_context_add_class (context, GTK_STYLE_CLASS_RUBBERBAND);

      path = gtk_tree_path_copy (rubberband_start);

      lines_rect.width = 0;

      while (gtk_tree_path_compare (path, rubberband_end) <= 0)
	{
	  gtk_tree_view_get_cell_area (GTK_TREE_VIEW (self),
				       path, self->priv->tree_col, &rect);
	  if (lines_rect.width == 0)
	    lines_rect = rect;
	  else
	    gdk_rectangle_union (&rect, &lines_rect, &lines_rect);

	  gtk_tree_path_next (path);
	}
      gtk_tree_path_free (path);

      gtk_render_background (context, cr,
			     lines_rect.x, lines_rect.y,
			     lines_rect.width, lines_rect.height);
      gtk_render_frame (context, cr,
			     lines_rect.x, lines_rect.y,
			     lines_rect.width, lines_rect.height);


      gtk_style_context_restore (context);
    }

  return FALSE;
}

static void
gd_main_list_view_scroll_to_path (GdMainViewGeneric *mv,
                                  GtkTreePath *path)
{
  gtk_tree_view_scroll_to_cell (GTK_TREE_VIEW (mv), path, NULL, TRUE, 0.5, 0.5);
}

static void
gd_main_list_view_set_model (GdMainViewGeneric *mv,
                             GtkTreeModel *model)
{
  gtk_tree_view_set_model (GTK_TREE_VIEW (mv), model);
}

static GtkTreeModel *
gd_main_list_view_get_model (GdMainViewGeneric *mv)
{
  return gtk_tree_view_get_model (GTK_TREE_VIEW (mv));
}

static void
gd_main_view_generic_iface_init (GdMainViewGenericIface *iface)
{
  iface->set_model = gd_main_list_view_set_model;
  iface->get_model = gd_main_list_view_get_model;
  iface->get_path_at_pos = gd_main_list_view_get_path_at_pos;
  iface->scroll_to_path = gd_main_list_view_scroll_to_path;
  iface->set_selection_mode = gd_main_list_view_set_selection_mode;
}

void
gd_main_list_view_add_renderer (GdMainListView *self,
                                GtkCellRenderer *renderer,
                                GtkTreeCellDataFunc func,
                                gpointer user_data,
                                GDestroyNotify destroy)
{
  gtk_tree_view_column_pack_start (self->priv->tree_col, renderer, FALSE);
  gtk_tree_view_column_set_cell_data_func (self->priv->tree_col, renderer,
                                           func, user_data, destroy);
}

GtkWidget *
gd_main_list_view_new (void)
{
  return g_object_new (GD_TYPE_MAIN_LIST_VIEW, NULL);
}
