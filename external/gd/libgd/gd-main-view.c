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

#include "gd-main-view.h"

#include "gd-icon-utils.h"
#include "gd-main-view-generic.h"
#include "gd-main-icon-view.h"
#include "gd-main-list-view.h"

#include <math.h>
#include <cairo-gobject.h>

#define MAIN_VIEW_TYPE_INITIAL -1
#define MAIN_VIEW_DND_ICON_OFFSET 20
#define MAIN_VIEW_RUBBERBAND_SELECT_TRIGGER_LENGTH 32

typedef struct _GdMainViewPrivate GdMainViewPrivate;

struct _GdMainViewPrivate {
  GdMainViewType current_type;
  gboolean selection_mode;

  GtkWidget *current_view;
  GtkTreeModel *model;

  gboolean track_motion;
  gboolean rubberband_select;
  GtkTreePath *rubberband_select_first_path;
  GtkTreePath *rubberband_select_last_path;
  int button_down_x;
  int button_down_y;

  gchar *button_press_item_path;

  gchar *last_selected_id;
};

enum {
  PROP_VIEW_TYPE = 1,
  PROP_SELECTION_MODE,
  PROP_MODEL,
  NUM_PROPERTIES
};

enum {
  ITEM_ACTIVATED = 1,
  SELECTION_MODE_REQUEST,
  VIEW_SELECTION_CHANGED,
  NUM_SIGNALS
};

static GParamSpec *properties[NUM_PROPERTIES] = { NULL, };
static guint signals[NUM_SIGNALS] = { 0, };

G_DEFINE_TYPE_WITH_PRIVATE (GdMainView, gd_main_view, GTK_TYPE_SCROLLED_WINDOW)

static void
gd_main_view_dispose (GObject *obj)
{
  GdMainView *self = GD_MAIN_VIEW (obj);
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  g_clear_object (&priv->model);

  G_OBJECT_CLASS (gd_main_view_parent_class)->dispose (obj);
}

static void
gd_main_view_finalize (GObject *obj)
{
  GdMainView *self = GD_MAIN_VIEW (obj);
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  g_free (priv->button_press_item_path);
  g_free (priv->last_selected_id);

  if (priv->rubberband_select_first_path)
    gtk_tree_path_free (priv->rubberband_select_first_path);

  if (priv->rubberband_select_last_path)
    gtk_tree_path_free (priv->rubberband_select_last_path);

  G_OBJECT_CLASS (gd_main_view_parent_class)->finalize (obj);
}

static void
gd_main_view_init (GdMainView *self)
{
  GdMainViewPrivate *priv;
  GtkStyleContext *context;

  priv = gd_main_view_get_instance_private (self);

  /* so that we get constructed with the right view even at startup */
  priv->current_type = MAIN_VIEW_TYPE_INITIAL;

  gtk_widget_set_hexpand (GTK_WIDGET (self), TRUE);
  gtk_widget_set_vexpand (GTK_WIDGET (self), TRUE);
  gtk_scrolled_window_set_shadow_type (GTK_SCROLLED_WINDOW (self), GTK_SHADOW_IN);
  gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (self),
                                  GTK_POLICY_NEVER,
                                  GTK_POLICY_AUTOMATIC);

  context = gtk_widget_get_style_context (GTK_WIDGET (self));
  gtk_style_context_add_class (context, "documents-scrolledwin");
}

static void
gd_main_view_get_property (GObject    *object,
                           guint       property_id,
                           GValue     *value,
                           GParamSpec *pspec)
{
  GdMainView *self = GD_MAIN_VIEW (object);

  switch (property_id)
    {
    case PROP_VIEW_TYPE:
      g_value_set_int (value, gd_main_view_get_view_type (self));
      break;
    case PROP_SELECTION_MODE:
      g_value_set_boolean (value, gd_main_view_get_selection_mode (self));
      break;
    case PROP_MODEL:
      g_value_set_object (value, gd_main_view_get_model (self));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_view_set_property (GObject    *object,
                           guint       property_id,
                           const GValue *value,
                           GParamSpec *pspec)
{
  GdMainView *self = GD_MAIN_VIEW (object);

  switch (property_id)
    {
    case PROP_VIEW_TYPE:
      gd_main_view_set_view_type (self, g_value_get_int (value));
      break;
    case PROP_SELECTION_MODE:
      gd_main_view_set_selection_mode (self, g_value_get_boolean (value));
      break;
    case PROP_MODEL:
      gd_main_view_set_model (self, g_value_get_object (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_view_class_init (GdMainViewClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);

  oclass->get_property = gd_main_view_get_property;
  oclass->set_property = gd_main_view_set_property;
  oclass->dispose = gd_main_view_dispose;
  oclass->finalize = gd_main_view_finalize;

  properties[PROP_VIEW_TYPE] =
    g_param_spec_int ("view-type",
                      "View type",
                      "View type",
                      GD_MAIN_VIEW_ICON,
                      GD_MAIN_VIEW_LIST,
                      GD_MAIN_VIEW_ICON,
                      G_PARAM_READWRITE |
                      G_PARAM_CONSTRUCT |
                      G_PARAM_STATIC_STRINGS);

  properties[PROP_SELECTION_MODE] =
    g_param_spec_boolean ("selection-mode",
                          "Selection mode",
                          "Whether the view is in selection mode",
                          FALSE,
                          G_PARAM_READWRITE |
                          G_PARAM_CONSTRUCT |
                          G_PARAM_STATIC_STRINGS);

  properties[PROP_MODEL] =
    g_param_spec_object ("model",
                         "Model",
                         "The GtkTreeModel",
                         GTK_TYPE_TREE_MODEL,
                         G_PARAM_READWRITE |
                         G_PARAM_CONSTRUCT |
                         G_PARAM_STATIC_STRINGS);

  signals[ITEM_ACTIVATED] =
    g_signal_new ("item-activated",
                  GD_TYPE_MAIN_VIEW,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL, NULL,
                  G_TYPE_NONE, 2,
                  G_TYPE_STRING, 
                  GTK_TYPE_TREE_PATH);

  signals[SELECTION_MODE_REQUEST] =
    g_signal_new ("selection-mode-request",
                  GD_TYPE_MAIN_VIEW,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL, NULL,
                  G_TYPE_NONE, 0);

  signals[VIEW_SELECTION_CHANGED] = 
    g_signal_new ("view-selection-changed",
                  GD_TYPE_MAIN_VIEW,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL, NULL,
                  G_TYPE_NONE, 0);

  g_object_class_install_properties (oclass, NUM_PROPERTIES, properties);
}

static GdMainViewGeneric *
get_generic (GdMainView *self)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  if (priv->current_view != NULL)
    return GD_MAIN_VIEW_GENERIC (priv->current_view);

  return NULL;
}

static void
do_select_row (GdMainView *self,
               GtkTreeIter *iter,
               gboolean value)
{
  GdMainViewPrivate *priv;
  GtkTreeModel *model;
  GtkTreeIter my_iter;
  GtkTreePath *path;

  priv = gd_main_view_get_instance_private (self);

  model = priv->model;
  my_iter = *iter;

  while (GTK_IS_TREE_MODEL_FILTER (model) ||
         GTK_IS_TREE_MODEL_SORT (model))
    {
      GtkTreeIter child_iter;

      if (GTK_IS_TREE_MODEL_FILTER (model))
        {
          GtkTreeModelFilter *filter;

          filter = GTK_TREE_MODEL_FILTER (model);
          gtk_tree_model_filter_convert_iter_to_child_iter (filter, &child_iter, &my_iter);
          model = gtk_tree_model_filter_get_model (filter);
        }
      else
        {
          GtkTreeModelSort *sort;

          sort = GTK_TREE_MODEL_SORT (model);
          gtk_tree_model_sort_convert_iter_to_child_iter (sort, &child_iter, &my_iter);
          model = gtk_tree_model_sort_get_model (sort);
        }

      my_iter = child_iter;
    }

  if (GTK_IS_LIST_STORE (model))
    {
      gtk_list_store_set (GTK_LIST_STORE (model), &my_iter,
                          GD_MAIN_COLUMN_SELECTED, value,
                          -1);
    }
  else
    {
      gtk_tree_store_set (GTK_TREE_STORE (model), &my_iter,
                          GD_MAIN_COLUMN_SELECTED, value,
                          -1);
    }

  /* And tell the view model that something changed */
  path = gtk_tree_model_get_path (priv->model, iter);
  if (path)
    {
      gtk_tree_model_row_changed (priv->model, path, iter);
      gtk_tree_path_free (path);
    }
}

static void
selection_mode_do_select_range (GdMainView *self,
                                GtkTreeIter *first_element,
                                GtkTreeIter *last_element)
{
  GdMainViewPrivate *priv;
  GtkTreeIter iter;
  GtkTreePath *path, *last_path;
  gboolean equal;

  priv = gd_main_view_get_instance_private (self);

  path = gtk_tree_model_get_path (priv->model, first_element);
  last_path = gtk_tree_model_get_path (priv->model, last_element);
  if (gtk_tree_path_compare (path, last_path) > 0)
    {
      gtk_tree_path_free (last_path);
      last_path = path;
      iter = *last_element;
    }
  else
    {
      gtk_tree_path_free (path);
      iter = *first_element;
    }

  do
    {
      do_select_row (self, &iter, TRUE);

      path = gtk_tree_model_get_path (priv->model, &iter);
      equal = (gtk_tree_path_compare (path, last_path) == 0);
      gtk_tree_path_free (path);

      if (equal)
        break;
    }
  while (gtk_tree_model_iter_next (priv->model, &iter));

  gtk_tree_path_free (last_path);
}

static void
selection_mode_select_range (GdMainView *self,
                             GtkTreeIter *iter)
{
  GdMainViewPrivate *priv;
  GtkTreeIter other;
  gboolean found = FALSE;
  gboolean selected;
  char *id;

  priv = gd_main_view_get_instance_private (self);

  if (priv->last_selected_id != NULL &&
      gtk_tree_model_get_iter_first (priv->model, &other))
    {
      do
	{
	  gtk_tree_model_get (priv->model, &other,
			      GD_MAIN_COLUMN_ID, &id,
			      -1);
	  if (g_strcmp0 (id, priv->last_selected_id) == 0)
	    {
	      g_free (id);
	      found = TRUE;
	      break;
	    }
	  g_free (id);
	}
      while (gtk_tree_model_iter_next (priv->model, &other));
    }

  if (!found)
    {
      other = *iter;
      while (gtk_tree_model_iter_previous (priv->model, &other))
	{
	  gtk_tree_model_get (priv->model, &other,
			      GD_MAIN_COLUMN_SELECTED, &selected,
			      -1);

	  if (selected)
	    {
	      found = TRUE;
	      break;
	    }
	}
    }

  if (!found)
    {
      other = *iter;
      while (gtk_tree_model_iter_next (priv->model, &other))
	{
	  gtk_tree_model_get (priv->model, &other,
			      GD_MAIN_COLUMN_SELECTED, &selected,
			      -1);
	  if (selected)
	    {
	      found = TRUE;
	      break;
	    }
	}
    }

  if (found)
    selection_mode_do_select_range (self, iter, &other);
  else
    {
      /* no other selected element found, just select the iter */
      do_select_row (self, iter, TRUE);
    }

  g_signal_emit (self, signals[VIEW_SELECTION_CHANGED], 0);
}

static gboolean
toggle_selection_for_path (GdMainView *self,
                           GtkTreePath *path,
                           gboolean select_range)
{
  GdMainViewPrivate *priv;
  gboolean selected;
  GtkTreeIter iter;
  char *id;

  priv = gd_main_view_get_instance_private (self);

  if (priv->model == NULL)
    return FALSE;

  if (!gtk_tree_model_get_iter (priv->model, &iter, path))
    return FALSE;

  gtk_tree_model_get (priv->model, &iter,
                      GD_MAIN_COLUMN_SELECTED, &selected,
                      -1);

  if (selected)
    {
      do_select_row (self, &iter, FALSE);
    }
  else if (!selected)
    {
      if (select_range)
        selection_mode_select_range (self, &iter);
      else
	{
	  gtk_tree_model_get (priv->model, &iter,
			      GD_MAIN_COLUMN_ID, &id,
			      -1);
	  g_free (priv->last_selected_id);
	  priv->last_selected_id = id;

          do_select_row (self, &iter, TRUE);
	}
    }

  g_signal_emit (self, signals[VIEW_SELECTION_CHANGED], 0);

  return FALSE;
}

static gboolean
activate_item_for_path (GdMainView *self,
                        GtkTreePath *path)
{
  GdMainViewPrivate *priv;
  GtkTreeIter iter;
  gchar *id;

  priv = gd_main_view_get_instance_private (self);

  if (priv->model == NULL)
    return FALSE;

  if (!gtk_tree_model_get_iter (priv->model, &iter, path))
    return FALSE;

  gtk_tree_model_get (priv->model, &iter,
                      GD_MAIN_COLUMN_ID, &id,
                      -1);

  g_signal_emit (self, signals[ITEM_ACTIVATED], 0, id, path);
  g_free (id);

  return FALSE;
}

static gboolean
on_button_release_selection_mode (GdMainView *self,
                                  GdkEventButton *event,
                                  GtkTreePath *path)
{
  return toggle_selection_for_path (self, path, ((event->state & GDK_SHIFT_MASK) != 0));
}

static gboolean
on_button_release_view_mode (GdMainView *self,
                             GdkEventButton *event,
                             GtkTreePath *path)
{
  return activate_item_for_path (self, path);
}

static gboolean
event_triggers_selection_mode (GdkEventButton *event)
{
  return
    (event->button == 3) ||
    ((event->button == 1) && (event->state & GDK_CONTROL_MASK));
}

static gboolean
on_button_release_event (GtkWidget *view,
                         GdkEventButton *event,
                         gpointer user_data)
{
  GdMainView *self = user_data;
  GdMainViewPrivate *priv;
  GdMainViewGeneric *generic = get_generic (self);
  GtkTreePath *path, *start_path, *end_path, *tmp_path;
  GtkTreeIter iter;
  gchar *button_release_item_path;
  gboolean selection_mode;
  gboolean res, same_item = FALSE;
  gboolean is_selected;

  priv = gd_main_view_get_instance_private (self);

  /* eat double/triple click events */
  if (event->type != GDK_BUTTON_RELEASE)
    return TRUE;

  path = gd_main_view_generic_get_path_at_pos (generic, event->x, event->y);

  if (path != NULL)
    {
      button_release_item_path = gtk_tree_path_to_string (path);
      if (g_strcmp0 (priv->button_press_item_path, button_release_item_path) == 0)
        same_item = TRUE;

      g_free (button_release_item_path);
    }

  g_free (priv->button_press_item_path);
  priv->button_press_item_path = NULL;

  priv->track_motion = FALSE;
  if (priv->rubberband_select)
    {
      priv->rubberband_select = FALSE;
      gd_main_view_generic_set_rubberband_range (get_generic (self), NULL, NULL);
      if (priv->rubberband_select_last_path)
	{
	  if (!priv->selection_mode)
	    g_signal_emit (self, signals[SELECTION_MODE_REQUEST], 0);
	  if (!priv->selection_mode)
	    {
	      res = FALSE;
	      goto out;
	    }

	  start_path = gtk_tree_path_copy (priv->rubberband_select_first_path);
	  end_path = gtk_tree_path_copy (priv->rubberband_select_last_path);
	  if (gtk_tree_path_compare (start_path, end_path) > 0)
	    {
	      tmp_path = start_path;
	      start_path = end_path;
	      end_path = tmp_path;
	    }

	  while (gtk_tree_path_compare (start_path, end_path) <= 0)
	    {
	      if (gtk_tree_model_get_iter (priv->model,
					   &iter, start_path))
		{
		  gtk_tree_model_get (priv->model, &iter,
				      GD_MAIN_COLUMN_SELECTED, &is_selected,
				      -1);
                  do_select_row (self, &iter, !is_selected);
		}

	      gtk_tree_path_next (start_path);
	    }

          g_signal_emit (self, signals[VIEW_SELECTION_CHANGED], 0);

	  gtk_tree_path_free (start_path);
	  gtk_tree_path_free (end_path);
	}

      g_clear_pointer (&priv->rubberband_select_first_path,
		       gtk_tree_path_free);
      g_clear_pointer (&priv->rubberband_select_last_path,
		       gtk_tree_path_free);

      res = TRUE;
      goto out;
    }

  if (!same_item)
    {
      res = FALSE;
      goto out;
    }

  selection_mode = priv->selection_mode;

  if (!selection_mode)
    {
      if (event_triggers_selection_mode (event))
        {
          g_signal_emit (self, signals[SELECTION_MODE_REQUEST], 0);
          if (!priv->selection_mode)
            {
              res = FALSE;
              goto out;
            }
          selection_mode = priv->selection_mode;
        }
    }

  if (selection_mode)
    res = on_button_release_selection_mode (self, event, path);
  else
    res = on_button_release_view_mode (self, event, path);

 out:
  gtk_tree_path_free (path);
  return res;
}

static gboolean
on_button_press_event (GtkWidget *view,
                       GdkEventButton *event,
                       gpointer user_data)
{
  GdMainView *self = user_data;
  GdMainViewPrivate *priv;
  GdMainViewGeneric *generic = get_generic (self);
  GtkTreePath *path;
  GList *selection, *l;
  GtkTreePath *sel_path;
  gboolean found = FALSE;
  gboolean force_selection;

  priv = gd_main_view_get_instance_private (self);

  path = gd_main_view_generic_get_path_at_pos (generic, event->x, event->y);

  if (path != NULL)
    priv->button_press_item_path = gtk_tree_path_to_string (path);

  force_selection = event_triggers_selection_mode (event);
  if (!priv->selection_mode && !force_selection)
    {
      gtk_tree_path_free (path);
      return FALSE;
    }

  if (path && !force_selection)
    {
      selection = gd_main_view_get_selection (self);

      for (l = selection; l != NULL; l = l->next)
	{
	  sel_path = l->data;
	  if (gtk_tree_path_compare (path, sel_path) == 0)
	    {
	      found = TRUE;
	      break;
	    }
	}

      if (selection != NULL)
	g_list_free_full (selection, (GDestroyNotify) gtk_tree_path_free);
    }

  /* if we did not find the item in the selection, block
   * drag and drop, while in selection mode
   */
  if (!found)
    {
      priv->track_motion = TRUE;
      priv->rubberband_select = FALSE;
      priv->rubberband_select_first_path = NULL;
      priv->rubberband_select_last_path = NULL;
      priv->button_down_x = event->x;
      priv->button_down_y = event->y;
      return TRUE;
    }
  else
    return FALSE;
}

static gboolean
on_motion_event (GtkWidget      *widget,
		 GdkEventMotion *event,
		 gpointer user_data)
{
  GdMainView *self = user_data;
  GdMainViewPrivate *priv;
  GtkTreePath *path;

  priv = gd_main_view_get_instance_private (self);

  if (priv->track_motion)
    {
      if (!priv->rubberband_select &&
	  (event->x - priv->button_down_x) * (event->x - priv->button_down_x) +
	  (event->y - priv->button_down_y) * (event->y - priv->button_down_y)  >
	  MAIN_VIEW_RUBBERBAND_SELECT_TRIGGER_LENGTH * MAIN_VIEW_RUBBERBAND_SELECT_TRIGGER_LENGTH)
	{
	  priv->rubberband_select = TRUE;
	  if (priv->button_press_item_path)
	    {
	      priv->rubberband_select_first_path =
		gtk_tree_path_new_from_string (priv->button_press_item_path);
	    }
	}

      if (priv->rubberband_select)
	{
	  path = gd_main_view_generic_get_path_at_pos (get_generic (self), event->x, event->y);
	  if (path != NULL)
	    {
	      if (priv->rubberband_select_first_path == NULL)
		priv->rubberband_select_first_path = gtk_tree_path_copy (path);

	      if (priv->rubberband_select_last_path == NULL ||
		  gtk_tree_path_compare (priv->rubberband_select_last_path, path) != 0)
		{
		  if (priv->rubberband_select_last_path)
		    gtk_tree_path_free (priv->rubberband_select_last_path);
		  priv->rubberband_select_last_path = path;

		  gd_main_view_generic_set_rubberband_range (get_generic (self),
							     priv->rubberband_select_first_path,
							     priv->rubberband_select_last_path);
		}
	      else
		gtk_tree_path_free (path);
	    }
	}
    }
  return FALSE;
}

static void
on_drag_begin (GdMainViewGeneric *generic,
               GdkDragContext *drag_context,
               gpointer user_data)
{
  GdMainView *self = user_data;
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  if (priv->button_press_item_path != NULL)
    {
      gboolean res;
      GtkTreeIter iter;
      gpointer data;
      cairo_surface_t *surface = NULL;
      GtkTreePath *path;
      GType column_gtype;

      path = gtk_tree_path_new_from_string (priv->button_press_item_path);
      res = gtk_tree_model_get_iter (priv->model,
                                     &iter, path);
      if (res)
        gtk_tree_model_get (priv->model, &iter,
                            GD_MAIN_COLUMN_ICON, &data,
                            -1);

      column_gtype = gtk_tree_model_get_column_type (priv->model,
                                                     GD_MAIN_COLUMN_ICON);

      if (column_gtype == CAIRO_GOBJECT_TYPE_SURFACE)
        {
          surface = gd_copy_image_surface (data);
          cairo_surface_destroy (data);
        }
      else if (column_gtype == GDK_TYPE_PIXBUF)
        {
          surface = gdk_cairo_surface_create_from_pixbuf (data, 1, NULL);
          g_object_unref (data);
        }
      else
        g_assert_not_reached ();

      if (priv->selection_mode &&
          surface != NULL)
        {
          GList *selection;
          cairo_surface_t *counter;

          selection = gd_main_view_get_selection (self);

          if (g_list_length (selection) > 1)
            {
              counter = gd_create_surface_with_counter (GTK_WIDGET (self), surface, g_list_length (selection));
              cairo_surface_destroy (surface);
              surface = counter;
            }

          if (selection != NULL)
            g_list_free_full (selection, (GDestroyNotify) gtk_tree_path_free);
        }

      if (surface != NULL)
        {
          cairo_surface_set_device_offset (surface,
                                           -MAIN_VIEW_DND_ICON_OFFSET,
                                           -MAIN_VIEW_DND_ICON_OFFSET);
          gtk_drag_set_icon_surface (drag_context, surface);
          cairo_surface_destroy (surface);
        }

      gtk_tree_path_free (path);
    }
}

static void
on_view_path_activated (GdMainView *self,
                        GtkTreePath *path)
{
  GdMainViewPrivate *priv;
  GdkModifierType state;

  priv = gd_main_view_get_instance_private (self);

  gtk_get_current_event_state (&state);

  if (priv->selection_mode || (state & GDK_CONTROL_MASK) != 0)
    {
      if (!priv->selection_mode)
	g_signal_emit (self, signals[SELECTION_MODE_REQUEST], 0);
      toggle_selection_for_path (self, path, ((state & GDK_SHIFT_MASK) != 0));
    }
  else
    activate_item_for_path (self, path);
}

static void
on_list_view_row_activated (GtkTreeView *tree_view,
                            GtkTreePath *path,
                            GtkTreeViewColumn *column,
                            gpointer user_data)
{
  GdMainView *self = user_data;
  on_view_path_activated (self, path);
}

static void
on_icon_view_item_activated (GtkIconView *icon_view,
                             GtkTreePath *path,
                             gpointer user_data)
{
  GdMainView *self = user_data;
  on_view_path_activated (self, path);
}

static void
on_view_selection_changed (GtkWidget *view,
                           gpointer user_data)
{
  GdMainView *self = user_data;

  g_signal_emit (self, signals[VIEW_SELECTION_CHANGED], 0);
}

static void
on_row_deleted_cb (GtkTreeModel *model,
                   GtkTreePath *path,
                   gpointer user_data)
{
  GdMainView *self = user_data;

  g_signal_emit (self, signals[VIEW_SELECTION_CHANGED], 0);
}

static void
gd_main_view_apply_model (GdMainView *self)
{
  GdMainViewPrivate *priv;
  GdMainViewGeneric *generic = get_generic (self);

  priv = gd_main_view_get_instance_private (self);
  gd_main_view_generic_set_model (generic, priv->model);
}

static void
gd_main_view_apply_selection_mode (GdMainView *self)
{
  GdMainViewPrivate *priv;
  GdMainViewGeneric *generic = get_generic (self);

  priv = gd_main_view_get_instance_private (self);

  gd_main_view_generic_set_selection_mode (generic, priv->selection_mode);

  if (!priv->selection_mode)
    {
      g_clear_pointer (&priv->last_selected_id, g_free);
      if (priv->model != NULL)
        gd_main_view_unselect_all (self);
    }
}

static void
gd_main_view_rebuild (GdMainView *self)
{
  GdMainViewPrivate *priv;
  GtkStyleContext *context;

  priv = gd_main_view_get_instance_private (self);

  if (priv->current_view != NULL)
    gtk_widget_destroy (priv->current_view);

  if (priv->current_type == GD_MAIN_VIEW_ICON)
    {
      priv->current_view = gd_main_icon_view_new ();
      g_signal_connect (priv->current_view, "item-activated",
                        G_CALLBACK (on_icon_view_item_activated), self);
    }
  else
    {
      priv->current_view = gd_main_list_view_new ();
      g_signal_connect (priv->current_view, "row-activated",
                        G_CALLBACK (on_list_view_row_activated), self);
    }

  context = gtk_widget_get_style_context (priv->current_view);
  gtk_style_context_add_class (context, "content-view");

  gtk_container_add (GTK_CONTAINER (self), priv->current_view);

  g_signal_connect (priv->current_view, "button-press-event",
                    G_CALLBACK (on_button_press_event), self);
  g_signal_connect (priv->current_view, "button-release-event",
                    G_CALLBACK (on_button_release_event), self);
  g_signal_connect (priv->current_view, "motion-notify-event",
                    G_CALLBACK (on_motion_event), self);
  g_signal_connect_after (priv->current_view, "drag-begin",
                          G_CALLBACK (on_drag_begin), self);
  g_signal_connect (priv->current_view, "view-selection-changed",
                    G_CALLBACK (on_view_selection_changed), self);

  gd_main_view_apply_model (self);
  gd_main_view_apply_selection_mode (self);

  gtk_widget_show_all (GTK_WIDGET (self));
}

GdMainView *
gd_main_view_new (GdMainViewType type)
{
  return g_object_new (GD_TYPE_MAIN_VIEW,
                       "view-type", type,
                       NULL);
}

void
gd_main_view_set_view_type (GdMainView *self,
                            GdMainViewType type)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  if (type != priv->current_type)
    {
      priv->current_type = type;
      gd_main_view_rebuild (self);

      g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_VIEW_TYPE]);
    }
}

GdMainViewType
gd_main_view_get_view_type (GdMainView *self)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);
  return priv->current_type;
}

void
gd_main_view_set_selection_mode (GdMainView *self,
                                 gboolean selection_mode)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  if (selection_mode != priv->selection_mode)
    {
      priv->selection_mode = selection_mode;
      gd_main_view_apply_selection_mode (self);
      g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_SELECTION_MODE]);
    }
}

gboolean
gd_main_view_get_selection_mode (GdMainView *self)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);
  return priv->selection_mode;
}

/**
 * gd_main_view_set_model:
 * @self:
 * @model: (allow-none):
 *
 */
void
gd_main_view_set_model (GdMainView *self,
                        GtkTreeModel *model)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);

  if (model != priv->model)
    {
      if (priv->model)
        g_signal_handlers_disconnect_by_func (priv->model,
                                              on_row_deleted_cb, self);

      g_clear_object (&priv->model);

      if (model)
        {
          priv->model = g_object_ref (model);
          g_signal_connect (priv->model, "row-deleted",
                            G_CALLBACK (on_row_deleted_cb), self);
        }
      else
        {
          priv->model = NULL;
        }

      gd_main_view_apply_model (self);
      g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_MODEL]);
    }
}

/**
 * gd_main_view_get_model:
 * @self:
 *
 * Returns: (transfer none):
 */
GtkTreeModel *
gd_main_view_get_model (GdMainView *self)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);
  return priv->model;
}

/**
 * gd_main_view_get_generic_view:
 * @self:
 *
 * Returns: (transfer none):
 */
GtkWidget *
gd_main_view_get_generic_view (GdMainView *self)
{
  GdMainViewPrivate *priv;

  priv = gd_main_view_get_instance_private (self);
  return priv->current_view;
}

static gboolean
build_selection_list_foreach (GtkTreeModel *model,
                              GtkTreePath *path,
                              GtkTreeIter *iter,
                              gpointer user_data)
{
  GList **sel = user_data;
  gboolean is_selected;

  gtk_tree_model_get (model, iter,
                      GD_MAIN_COLUMN_SELECTED, &is_selected,
                      -1);

  if (is_selected)
    *sel = g_list_prepend (*sel, gtk_tree_path_copy (path));

  return FALSE;
}

/**
 * gd_main_view_get_selection:
 * @self:
 *
 * Returns: (element-type GtkTreePath) (transfer full):
 */
GList *
gd_main_view_get_selection (GdMainView *self)
{
  GdMainViewPrivate *priv;
  GList *retval = NULL;

  priv = gd_main_view_get_instance_private (self);

  gtk_tree_model_foreach (priv->model,
                          build_selection_list_foreach,
                          &retval);

  return g_list_reverse (retval);
}

void
gd_main_view_select_all (GdMainView *self)
{
  GdMainViewGeneric *generic = get_generic (self);

  gd_main_view_generic_select_all (generic);
}

void
gd_main_view_unselect_all (GdMainView *self)
{
  GdMainViewGeneric *generic = get_generic (self);

  gd_main_view_generic_unselect_all (generic);
}
