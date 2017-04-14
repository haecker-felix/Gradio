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

#include <math.h>

#include <cairo.h>
#include <gio/gio.h>

#include "gd-icon-utils.h"
#include "gd-main-icon-box.h"
#include "gd-main-icon-box-child.h"
#include "gd-main-box-child.h"
#include "gd-main-box-generic.h"
#include "gd-main-box-item.h"

#define MAIN_ICON_BOX_DND_ICON_OFFSET 20

typedef struct _GdMainIconBoxPrivate GdMainIconBoxPrivate;

struct _GdMainIconBoxPrivate
{
  GListModel *model;
  gboolean dnd_started;
  gboolean key_pressed;
  gboolean key_shift_pressed;
  gboolean left_button_released;
  gboolean left_button_shift_released;
  gboolean selection_changed;
  gboolean selection_mode;
  gboolean show_primary_text;
  gboolean show_secondary_text;
  gchar *last_selected_id;
  gdouble dnd_start_x;
  gdouble dnd_start_y;
  gint dnd_button;
};

enum
{
  PROP_LAST_SELECTED_ID = 1,
  PROP_MODEL,
  PROP_SELECTION_MODE,
  PROP_SHOW_PRIMARY_TEXT,
  PROP_SHOW_SECONDARY_TEXT,
  NUM_PROPERTIES
};

static void gd_main_box_generic_interface_init (GdMainBoxGenericInterface *iface);
G_DEFINE_TYPE_WITH_CODE (GdMainIconBox, gd_main_icon_box, GTK_TYPE_FLOW_BOX,
                         G_ADD_PRIVATE (GdMainIconBox)
                         G_IMPLEMENT_INTERFACE (GD_TYPE_MAIN_BOX_GENERIC, gd_main_box_generic_interface_init))

GtkWidget *
gd_main_icon_box_create_widget_func (gpointer item, gpointer user_data)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (user_data);
  GdMainIconBoxPrivate *priv;
  GtkWidget *child;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (item), NULL);

  priv = gd_main_icon_box_get_instance_private (self);

  child = gd_main_icon_box_child_new (GD_MAIN_BOX_ITEM (item), priv->selection_mode);
  g_object_bind_property (self, "show-primary-text", child, "show-primary-text", G_BINDING_SYNC_CREATE);
  g_object_bind_property (self, "show-secondary-text", child, "show-secondary-text", G_BINDING_SYNC_CREATE);
  gtk_widget_show_all (child);

  return child;
}

static void
gd_main_icon_box_update_last_selected_id (GdMainIconBox *self, GdMainBoxChild *child)
{
  GdMainIconBoxPrivate *priv;
  GdMainBoxItem *item;
  const gchar *id = NULL;

  priv = gd_main_icon_box_get_instance_private (self);

  if (child != NULL)
    {
      item = gd_main_box_child_get_item (child);
      id = gd_main_box_item_get_id (item);
    }

  if (g_strcmp0 (priv->last_selected_id, id) != 0)
    {
      g_free (priv->last_selected_id);
      priv->last_selected_id = g_strdup (id);
      g_object_notify (G_OBJECT (self), "last-selected-id");
    }
}

static GdMainBoxChild *
gd_main_icon_box_get_child_at_index (GdMainBoxGeneric *generic, gint index)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  GtkFlowBoxChild *child;

  child = gtk_flow_box_get_child_at_index (GTK_FLOW_BOX (self), index);
  return GD_MAIN_BOX_CHILD (child);
}

static const gchar *
gd_main_icon_box_get_last_selected_id (GdMainBoxGeneric *generic)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);
  return priv->last_selected_id;
}

static GListModel *
gd_main_icon_box_get_model (GdMainBoxGeneric *generic)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);
  return priv->model;
}

static GList *
gd_main_icon_box_get_selected_children (GdMainBoxGeneric *generic)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  GList *selected_children;

  selected_children = gtk_flow_box_get_selected_children (GTK_FLOW_BOX (self));
  return selected_children;
}

static gboolean
gd_main_icon_box_get_selection_mode (GdMainIconBox *self)
{
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);
  return priv->selection_mode;
}

static gboolean
gd_main_icon_box_get_show_primary_text (GdMainIconBox *self)
{
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);
  return priv->show_primary_text;
}

static gboolean
gd_main_icon_box_get_show_secondary_text (GdMainIconBox *self)
{
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);
  return priv->show_secondary_text;
}

static void
gd_main_icon_box_select_all_generic (GdMainBoxGeneric *generic)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  g_signal_emit_by_name (self, "select-all");
}

static void
gd_main_icon_box_select_child (GdMainBoxGeneric *generic, GdMainBoxChild *child)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  gtk_flow_box_select_child (GTK_FLOW_BOX (self), GTK_FLOW_BOX_CHILD (child));
}

static void
gd_main_icon_box_set_model (GdMainIconBox *self, GListModel *model)
{
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  if (!g_set_object (&priv->model, model))
    return;

  gtk_flow_box_bind_model (GTK_FLOW_BOX (self),
                           priv->model,
                           gd_main_icon_box_create_widget_func,
                           self,
                           NULL);

  g_object_notify (G_OBJECT (self), "model");
}

static void
gd_main_icon_box_set_selection_mode (GdMainIconBox *self, gboolean selection_mode)
{
  GdMainIconBoxPrivate *priv;
  GList *children;
  GList *l;

  priv = gd_main_icon_box_get_instance_private (self);

  if (priv->selection_mode == selection_mode)
    return;

  gd_main_icon_box_update_last_selected_id (self, NULL);

  priv->selection_mode = selection_mode;
  if (priv->selection_mode)
    gtk_flow_box_set_selection_mode (GTK_FLOW_BOX (self), GTK_SELECTION_MULTIPLE);
  else
    gtk_flow_box_set_selection_mode (GTK_FLOW_BOX (self), GTK_SELECTION_NONE);

  children = gtk_container_get_children (GTK_CONTAINER (self));
  for (l = children; l != NULL; l = l->next)
    {
      GdMainBoxChild *child = GD_MAIN_BOX_CHILD (l->data);
      gd_main_box_child_set_selection_mode (child, priv->selection_mode);
    }

  g_object_notify (G_OBJECT (self), "last-selected-id");
  g_object_notify (G_OBJECT (self), "selection-mode");

  g_list_free (children);
}

static void
gd_main_icon_box_set_show_primary_text (GdMainIconBox *self, gboolean show_primary_text)
{
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  if (priv->show_primary_text == show_primary_text)
    return;

  priv->show_primary_text = show_primary_text;
  g_object_notify (G_OBJECT (self), "show-primary-text");
}

static void
gd_main_icon_box_set_show_secondary_text (GdMainIconBox *self, gboolean show_secondary_text)
{
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  if (priv->show_secondary_text == show_secondary_text)
    return;

  priv->show_secondary_text = show_secondary_text;
  g_object_notify (G_OBJECT (self), "show-secondary-text");
}

static void
gd_main_icon_box_unselect_all_generic (GdMainBoxGeneric *generic)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  g_signal_emit_by_name (self, "unselect-all");
}

static void
gd_main_icon_box_unselect_child (GdMainBoxGeneric *generic, GdMainBoxChild *child)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (generic);
  gtk_flow_box_unselect_child (GTK_FLOW_BOX (self), GTK_FLOW_BOX_CHILD (child));
}

static void
gd_main_icon_box_activate_cursor_child (GtkFlowBox *flow_box)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (flow_box);
  GdMainIconBoxPrivate *priv;
  GdkEvent *event = NULL;
  gboolean initiating = FALSE;

  priv = gd_main_icon_box_get_instance_private (self);

  /* Use GtkFlowBox::activate-cursor-child instead of
   * GtkWidget::key-press-event to catch key presses because it is
   * easier to filter out non-activation keys.
   */

  event = gtk_get_current_event ();
  if (event == NULL)
    goto out;

  if (event->type != GDK_KEY_PRESS)
    goto out;

  if (!priv->selection_mode && (event->key.state & GDK_CONTROL_MASK) != 0)
    {
      g_signal_emit_by_name (self, "selection-mode-request");
      initiating = TRUE;
    }

  if (priv->selection_mode)
    {
      if (!initiating && (event->key.state & GDK_SHIFT_MASK) != 0)
        priv->key_shift_pressed = TRUE;

      priv->key_pressed = TRUE;
    }

 out:
  GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->activate_cursor_child (flow_box);
  g_clear_pointer (&event, (GDestroyNotify) gdk_event_free);
}

static gboolean
gd_main_icon_box_button_press_event (GtkWidget *widget, GdkEventButton *event)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (widget);
  GdMainIconBoxPrivate *priv;
  GtkFlowBoxChild *child;
  gboolean res;

  priv = gd_main_icon_box_get_instance_private (self);

  if (event->type != GDK_BUTTON_PRESS)
    {
      res = GDK_EVENT_STOP;
      goto out;
    }

  if (event->button != GDK_BUTTON_PRIMARY)
    goto default_behavior;

  child = gtk_flow_box_get_child_at_pos (GTK_FLOW_BOX (self), (gint) event->x, (gint) event->y);
  if (child == NULL)
    goto default_behavior;

  if (priv->selection_mode && !gtk_flow_box_child_is_selected (child))
    goto default_behavior;

  priv->dnd_button = (gint) event->button;
  priv->dnd_start_x = event->x;
  priv->dnd_start_y = event->y;

 default_behavior:
  res = GTK_WIDGET_CLASS (gd_main_icon_box_parent_class)->button_press_event (widget, event);

 out:
  return res;
}

static gboolean
gd_main_icon_box_button_release_event (GtkWidget *widget, GdkEventButton *event)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (widget);
  GdMainIconBoxPrivate *priv;
  GtkFlowBoxChild *child = NULL;
  gboolean initiating = FALSE;
  gboolean res;

  priv = gd_main_icon_box_get_instance_private (self);

  priv->dnd_button = -1;
  priv->dnd_start_x = -1.0;
  priv->dnd_start_y = -1.0;
  priv->dnd_started = FALSE;

  if (event->type != GDK_BUTTON_RELEASE)
    {
      res = GDK_EVENT_STOP;
      goto out;
    }

  if (!priv->selection_mode &&
      (event->button == GDK_BUTTON_PRIMARY && (event->state & GDK_CONTROL_MASK) != 0 ||
       event->button == GDK_BUTTON_SECONDARY))
    {
      g_signal_emit_by_name (self, "selection-mode-request");
      initiating = TRUE;
    }

  if (priv->selection_mode)
    {
      if (event->button == GDK_BUTTON_PRIMARY)
        {
          /* GtkFlowBox doesn't do range selection. It will simply
           * select a single child for shift + left-click. We need to
           * detect it so that we can handle it later.
           *
           * However, range selection is only possible if we were
           * already in the selection mode. Therefore, skip it if we
           * have just requested the selection mode.
           */
          if (!initiating && (event->state & GDK_SHIFT_MASK) != 0)
            priv->left_button_shift_released = TRUE;

          priv->left_button_released = TRUE;
        }
      else if (event->button == GDK_BUTTON_SECONDARY)
        {
          /* GtkFlowBox completely ignores the right mouse
           * button.
           */

          child = gtk_flow_box_get_child_at_pos (GTK_FLOW_BOX (self), (gint) event->x, (gint) event->y);
          if (child != NULL)
            {
              gd_main_box_generic_toggle_selection_for_child (GD_MAIN_BOX_GENERIC (self),
                                                              GD_MAIN_BOX_CHILD (child),
                                                              (!initiating &&
                                                               (event->state & GDK_SHIFT_MASK) != 0));
            }
        }
    }

  /* This is for right-clicks and rubberband selection.
   *
   * Rubberband selection is unlike other modes of selection because
   * GtkFlowBox::selected-children-changed is emitted before the mouse
   * button is released.
   */
  if (priv->selection_changed)
    {
      g_signal_emit_by_name (self, "selection-changed");
      gd_main_icon_box_update_last_selected_id (self, GD_MAIN_BOX_CHILD (child));
      priv->selection_changed = FALSE;
    }

  res = GTK_WIDGET_CLASS (gd_main_icon_box_parent_class)->button_release_event (widget, event);

 out:
  return res;
}

static void
gd_main_icon_box_child_activated (GtkFlowBox *flow_box, GtkFlowBoxChild *child)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (flow_box);
  GdMainIconBoxPrivate *priv;
  GdkEvent *event = NULL;

  g_return_if_fail (GD_IS_MAIN_BOX_CHILD (child));

  priv = gd_main_icon_box_get_instance_private (self);

  /* GtkFlowBox might emit child-activated in the middle of a
   * DnD. See https://bugzilla.gnome.org/show_bug.cgi?id=776306
   */
  if (priv->dnd_started)
    goto out;

  if (!priv->selection_mode)
    {
      g_signal_emit_by_name (self, "item-activated", GD_MAIN_BOX_CHILD (child));
      goto out;
    }

  event = gtk_get_current_event ();
  if (event == NULL)
    goto out;

  if (priv->left_button_released && !priv->selection_changed)
    {
      /* If a selected child is left-clicked, GtkFlowBox will activate
       * it without unselecting it.
       */
      gd_main_box_generic_toggle_selection_for_child (GD_MAIN_BOX_GENERIC (self),
                                                      GD_MAIN_BOX_CHILD (child),
                                                      FALSE); /* One cannot unselect a range. */
      priv->left_button_released = FALSE;
      g_signal_emit_by_name (self, "selection-changed");
    }
  else if (priv->key_pressed && !priv->selection_changed)
    {
      /* If a selected child is activated by a keybinding, GtkFlowBox
       * will not unselect it.
       */
      gd_main_box_generic_toggle_selection_for_child (GD_MAIN_BOX_GENERIC (self), GD_MAIN_BOX_CHILD (child), FALSE);
      priv->key_pressed = FALSE;
      g_signal_emit_by_name (self, "selection-changed");
    }
  else if (priv->left_button_shift_released || priv->key_shift_pressed)
    {
      /* GtkFlowBox doesn't do range selection and simply selects a
       * single child. We handle it by unselecting the child and then
       * selecting the range.
       */
      gd_main_box_generic_toggle_selection_for_child (GD_MAIN_BOX_GENERIC (self), GD_MAIN_BOX_CHILD (child), FALSE);
      priv->left_button_shift_released = FALSE;
      priv->key_shift_pressed = FALSE;
      gd_main_box_generic_toggle_selection_for_child (GD_MAIN_BOX_GENERIC (self), GD_MAIN_BOX_CHILD (child), TRUE);
      g_signal_emit_by_name (self, "selection-changed");
    }
  else if (priv->selection_changed)
    {
      /* This is for non-shift left-clicks and keyboard activation of
       * unselected children.
       */
      g_signal_emit_by_name (self, "selection-changed");
    }

  g_signal_emit_by_name (self, "item-activated", GD_MAIN_BOX_CHILD (child));

  if (priv->selection_changed)
    {
      gd_main_icon_box_update_last_selected_id (self, GD_MAIN_BOX_CHILD (child));
      priv->selection_changed = FALSE;
    }

 out:
  g_clear_pointer (&event, (GDestroyNotify) gdk_event_free);
}

static void
gd_main_icon_box_drag_begin (GtkWidget *widget, GdkDragContext *context)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (widget);
  GdMainIconBoxPrivate *priv;
  GdMainBoxItem *item;
  GtkFlowBoxChild *child;
  cairo_surface_t *drag_icon = NULL;
  cairo_surface_t *icon;

  priv = gd_main_icon_box_get_instance_private (self);

  if (priv->dnd_start_x < 0.0 || priv->dnd_start_y < 0.0)
    goto out;

  child = gtk_flow_box_get_child_at_pos (GTK_FLOW_BOX (self),
                                         (gint) priv->dnd_start_x,
                                         (gint) priv->dnd_start_y);
  if (child == NULL)
    goto out;

  item = gd_main_box_child_get_item (GD_MAIN_BOX_CHILD (child));
  icon = gd_main_box_item_get_icon (item);
  if (icon == NULL)
    goto out;

  if (priv->selection_mode)
    {
      GList *selected_children;
      guint length;

      selected_children = gtk_flow_box_get_selected_children (GTK_FLOW_BOX (self));
      length = g_list_length (selected_children);
      if (length > 1)
        drag_icon = gd_create_surface_with_counter (GTK_WIDGET (self), icon, length);

      g_list_free (selected_children);
    }

  if (drag_icon == NULL)
    drag_icon = gd_copy_image_surface (icon);

  cairo_surface_set_device_offset (drag_icon, -MAIN_ICON_BOX_DND_ICON_OFFSET, -MAIN_ICON_BOX_DND_ICON_OFFSET);
  gtk_drag_set_icon_surface (context, drag_icon);

 out:
  g_clear_pointer (&drag_icon, (GDestroyNotify) cairo_surface_destroy);
}

static void
gd_main_icon_box_add_child_uri_to_array (GdMainBoxChild *child, GPtrArray *uri_array)
{
  GdMainBoxItem *item;
  const gchar *uri;

  item = gd_main_box_child_get_item (child);
  uri = gd_main_box_item_get_uri (item);
  g_ptr_array_add (uri_array, g_strdup (uri));
}

static void
gd_main_icon_box_drag_data_get (GtkWidget *widget,
                                GdkDragContext *context,
                                GtkSelectionData *data,
                                guint info,
                                guint time)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (widget);
  GdMainIconBoxPrivate *priv;
  GPtrArray *uri_array = NULL;
  gchar **uris = NULL;

  priv = gd_main_icon_box_get_instance_private (self);

  if (info != 0)
    goto out;

  if (priv->dnd_start_x < 0.0 || priv->dnd_start_y < 0.0)
    goto out;

  uri_array = g_ptr_array_new_with_free_func (g_free);

  if (priv->selection_mode)
    {
      GList *l;
      GList *selected_children;

      selected_children = gtk_flow_box_get_selected_children (GTK_FLOW_BOX (self));
      for (l = selected_children; l != NULL; l = l->next)
        {
          GdMainBoxChild *child = GD_MAIN_BOX_CHILD (l->data);
          gd_main_icon_box_add_child_uri_to_array (child, uri_array);
        }

      g_list_free (selected_children);
    }
  else
    {
      GtkFlowBoxChild *child;

      child = gtk_flow_box_get_child_at_pos (GTK_FLOW_BOX (self),
                                             (gint) priv->dnd_start_x,
                                             (gint) priv->dnd_start_y);

      if (child != NULL)
        gd_main_icon_box_add_child_uri_to_array (GD_MAIN_BOX_CHILD (child), uri_array);
    }

  g_ptr_array_add (uri_array, NULL);
  gtk_selection_data_set_uris (data, (gchar **) uri_array->pdata);

 out:
  g_clear_pointer (&uri_array, (GDestroyNotify) g_ptr_array_unref);
}

static gboolean
gd_main_icon_box_focus (GtkWidget *widget, GtkDirectionType direction)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (widget);
  GdMainIconBoxPrivate *priv;
  GdkEvent *event = NULL;
  GdkEvent *fake_event = NULL;
  gboolean res;

  priv = gd_main_icon_box_get_instance_private (self);

  if (!priv->selection_mode)
    {
      res = GTK_WIDGET_CLASS (gd_main_icon_box_parent_class)->focus (widget, direction);
      goto out;
    }

  event = gtk_get_current_event ();
  if (event->type != GDK_KEY_PRESS && event->type != GDK_KEY_RELEASE)
    {
      res = GTK_WIDGET_CLASS (gd_main_icon_box_parent_class)->focus (widget, direction);
      goto out;
    }

  if ((event->key.state & GDK_CONTROL_MASK) != 0)
    {
      res = GTK_WIDGET_CLASS (gd_main_icon_box_parent_class)->focus (widget, direction);
      goto out;
    }

  fake_event = gdk_event_copy (event);
  fake_event->key.state |= GDK_CONTROL_MASK;

  gtk_main_do_event (fake_event);
  res = GDK_EVENT_STOP;

 out:
  g_clear_pointer (&fake_event, (GDestroyNotify) gdk_event_free);
  g_clear_pointer (&event, (GDestroyNotify) gdk_event_free);
  return res;
}

static gboolean
gd_main_icon_box_motion_notify_event (GtkWidget *widget, GdkEventMotion *event)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (widget);
  GdMainIconBoxPrivate *priv;
  GtkTargetList *targets;
  gboolean res;
  gint button;

  priv = gd_main_icon_box_get_instance_private (self);

  if (priv->dnd_button < 0)
    goto out;

  if (!gtk_drag_check_threshold (GTK_WIDGET (self),
                                 (gint) priv->dnd_start_x,
                                 (gint) priv->dnd_start_y,
                                 (gint) event->x,
                                 (gint) event->y))
      goto out;

  button = priv->dnd_button;
  priv->dnd_button = -1;
  priv->dnd_started = TRUE;

  targets = gtk_drag_source_get_target_list (GTK_WIDGET (self));

  gtk_drag_begin_with_coordinates (GTK_WIDGET (self),
                                   targets,
                                   GDK_ACTION_COPY,
                                   button,
                                   (GdkEvent *) event,
                                   (gint) priv->dnd_start_x,
                                   (gint) priv->dnd_start_y);

 out:
  res = GTK_WIDGET_CLASS (gd_main_icon_box_parent_class)->motion_notify_event (widget, event);
  return res;
}

static gboolean
gd_main_icon_box_move_cursor (GtkFlowBox *flow_box, GtkMovementStep step, gint count)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (flow_box);
  GdMainIconBoxPrivate *priv;
  GdkEvent *event = NULL;
  GdkEvent *fake_event = NULL;
  gboolean res;

  priv = gd_main_icon_box_get_instance_private (self);

  if (!priv->selection_mode)
    {
      res = GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->move_cursor (flow_box, step, count);
      goto out;
    }

  event = gtk_get_current_event ();
  if (event->type != GDK_KEY_PRESS && event->type != GDK_KEY_RELEASE)
    {
      res = GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->move_cursor (flow_box, step, count);
      goto out;
    }

  if ((event->key.state & GDK_CONTROL_MASK) != 0 && (event->key.state & GDK_SHIFT_MASK) == 0)
    {
      res = GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->move_cursor (flow_box, step, count);
      goto out;
    }

  fake_event = gdk_event_copy (event);
  fake_event->key.state |= GDK_CONTROL_MASK;
  fake_event->key.state &= ~GDK_SHIFT_MASK;

  gtk_main_do_event (fake_event);
  res = GDK_EVENT_STOP;

 out:
  g_clear_pointer (&fake_event, (GDestroyNotify) gdk_event_free);
  g_clear_pointer (&event, (GDestroyNotify) gdk_event_free);
  return res;
}

static void
gd_main_icon_box_remove (GtkContainer *container, GtkWidget *widget)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (container);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  GTK_CONTAINER_CLASS (gd_main_icon_box_parent_class)->remove (container, widget);

  if (priv->selection_changed)
    {
      g_signal_emit_by_name (self, "selection-changed");
      priv->selection_changed = FALSE;
    }
}

static void
gd_main_icon_box_select_all_flow_box (GtkFlowBox *flow_box)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (flow_box);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->select_all (flow_box);

  if (priv->selection_changed)
    {
      g_signal_emit_by_name (self, "selection-changed");
      priv->selection_changed = FALSE;
    }
}

static void
gd_main_icon_box_selected_children_changed (GtkFlowBox *flow_box)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (flow_box);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->selected_children_changed (flow_box);

  priv->selection_changed = TRUE;

  /* When a range selection is attempted, we override GtkFlowBox's
   * default behaviour by changing the selection ourselves. Therefore,
   * there is no need to update the check buttons until the final
   * selection is available.
   */
  if (!priv->key_shift_pressed && !priv->left_button_shift_released)
    {
      GList *children;
      GList *l;

      children = gtk_container_get_children (GTK_CONTAINER (self));
      for (l = children; l != NULL; l = l->next)
        {
          GtkFlowBoxChild *child = GTK_FLOW_BOX_CHILD (l->data);
          gboolean selected;

          /* Work around the fact that GtkFlowBoxChild:selected is not
           * a property.
           */
          selected = gtk_flow_box_child_is_selected (child);
          gd_main_box_child_set_selected (GD_MAIN_BOX_CHILD (child), selected);
        }

      g_list_free (children);
    }
}

static void
gd_main_icon_box_unselect_all_flow_box (GtkFlowBox *flow_box)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (flow_box);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  GTK_FLOW_BOX_CLASS (gd_main_icon_box_parent_class)->unselect_all (flow_box);

  if (priv->selection_changed)
    {
      g_signal_emit_by_name (self, "selection-changed");
      priv->selection_changed = FALSE;
    }
}

static void
gd_main_icon_box_dispose (GObject *obj)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (obj);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  g_clear_object (&priv->model);

  G_OBJECT_CLASS (gd_main_icon_box_parent_class)->dispose (obj);
}

static void
gd_main_icon_box_finalize (GObject *obj)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (obj);
  GdMainIconBoxPrivate *priv;

  priv = gd_main_icon_box_get_instance_private (self);

  g_free (priv->last_selected_id);

  G_OBJECT_CLASS (gd_main_icon_box_parent_class)->finalize (obj);
}

static void
gd_main_icon_box_get_property (GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (object);

  switch (property_id)
    {
    case PROP_LAST_SELECTED_ID:
      g_value_set_string (value, gd_main_icon_box_get_last_selected_id (GD_MAIN_BOX_GENERIC (self)));
      break;
    case PROP_MODEL:
      g_value_set_object (value, gd_main_icon_box_get_model (GD_MAIN_BOX_GENERIC (self)));
      break;
    case PROP_SELECTION_MODE:
      g_value_set_boolean (value, gd_main_icon_box_get_selection_mode (self));
      break;
    case PROP_SHOW_PRIMARY_TEXT:
      g_value_set_boolean (value, gd_main_icon_box_get_show_primary_text (self));
      break;
    case PROP_SHOW_SECONDARY_TEXT:
      g_value_set_boolean (value, gd_main_icon_box_get_show_secondary_text (self));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_icon_box_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec)
{
  GdMainIconBox *self = GD_MAIN_ICON_BOX (object);

  switch (property_id)
    {
    case PROP_MODEL:
      gd_main_icon_box_set_model (self, g_value_get_object (value));
      break;
    case PROP_SELECTION_MODE:
      gd_main_icon_box_set_selection_mode (self, g_value_get_boolean (value));
      break;
    case PROP_SHOW_PRIMARY_TEXT:
      gd_main_icon_box_set_show_primary_text (self, g_value_get_boolean (value));
      break;
    case PROP_SHOW_SECONDARY_TEXT:
      gd_main_icon_box_set_show_secondary_text (self, g_value_get_boolean (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_icon_box_init (GdMainIconBox *self)
{
  GdMainIconBoxPrivate *priv;
  const GtkTargetEntry targets[] = { { (gchar *) "text/uri-list", GTK_TARGET_OTHER_APP, 0 } };

  priv = gd_main_icon_box_get_instance_private (self);

  gtk_widget_set_can_focus (GTK_WIDGET (self), TRUE);
  gtk_flow_box_set_homogeneous (GTK_FLOW_BOX (self), TRUE);
  gtk_flow_box_set_min_children_per_line (GTK_FLOW_BOX (self), 3);
  gtk_flow_box_set_selection_mode (GTK_FLOW_BOX (self), GTK_SELECTION_NONE);

  /* We need to ensure that rubberband selection and DnD don't step
   * on each others toes. We set start_button_mask to 0 to retain
   * control over when to begin a drag.
   */
  gtk_drag_source_set (GTK_WIDGET (self), 0, targets, G_N_ELEMENTS (targets), GDK_ACTION_COPY);

  priv->dnd_button = -1;
  priv->dnd_start_x = -1.0;
  priv->dnd_start_y = -1.0;
}

static void
gd_main_icon_box_class_init (GdMainIconBoxClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);
  GtkContainerClass *cclass = GTK_CONTAINER_CLASS (klass);
  GtkFlowBoxClass *fbclass = GTK_FLOW_BOX_CLASS (klass);
  GtkWidgetClass *wclass = GTK_WIDGET_CLASS (klass);
  GtkBindingSet *binding_set;
  GdkModifierType activate_modifiers[] = { 0, /* Otherwise it will go to GtkFlowBoxChild::activate. */
                                           GDK_SHIFT_MASK,
                                           GDK_CONTROL_MASK,
                                           GDK_SHIFT_MASK | GDK_CONTROL_MASK };
  guint i;

  binding_set = gtk_binding_set_by_class (klass);

  oclass->dispose = gd_main_icon_box_dispose;
  oclass->finalize = gd_main_icon_box_finalize;
  oclass->get_property = gd_main_icon_box_get_property;
  oclass->set_property = gd_main_icon_box_set_property;
  wclass->button_press_event = gd_main_icon_box_button_press_event;
  wclass->button_release_event = gd_main_icon_box_button_release_event;
  wclass->drag_begin = gd_main_icon_box_drag_begin;
  wclass->drag_data_get = gd_main_icon_box_drag_data_get;
  wclass->focus = gd_main_icon_box_focus;
  wclass->motion_notify_event = gd_main_icon_box_motion_notify_event;
  cclass->remove = gd_main_icon_box_remove;
  fbclass->activate_cursor_child = gd_main_icon_box_activate_cursor_child;
  fbclass->child_activated = gd_main_icon_box_child_activated;
  fbclass->move_cursor = gd_main_icon_box_move_cursor;
  fbclass->select_all = gd_main_icon_box_select_all_flow_box;
  fbclass->selected_children_changed = gd_main_icon_box_selected_children_changed;
  fbclass->unselect_all = gd_main_icon_box_unselect_all_flow_box;

  g_object_class_override_property (oclass, PROP_LAST_SELECTED_ID, "last-selected-id");
  g_object_class_override_property (oclass, PROP_MODEL, "model");
  g_object_class_override_property (oclass, PROP_SELECTION_MODE, "gd-selection-mode");
  g_object_class_override_property (oclass, PROP_SHOW_PRIMARY_TEXT, "show-primary-text");
  g_object_class_override_property (oclass, PROP_SHOW_SECONDARY_TEXT, "show-secondary-text");

  for (i = 0; i < G_N_ELEMENTS (activate_modifiers); i++)
    {
      gtk_binding_entry_add_signal (binding_set,
                                    GDK_KEY_space, activate_modifiers[i],
                                    "activate-cursor-child",
                                    0);
      gtk_binding_entry_add_signal (binding_set,
                                    GDK_KEY_KP_Space, activate_modifiers[i],
                                    "activate-cursor-child",
                                    0);
      gtk_binding_entry_add_signal (binding_set,
                                    GDK_KEY_Return, activate_modifiers[i],
                                    "activate-cursor-child",
                                    0);
      gtk_binding_entry_add_signal (binding_set,
                                    GDK_KEY_ISO_Enter, activate_modifiers[i],
                                    "activate-cursor-child",
                                    0);
      gtk_binding_entry_add_signal (binding_set,
                                    GDK_KEY_KP_Enter, activate_modifiers[i],
                                    "activate-cursor-child",
                                    0);
    }
}

static void
gd_main_box_generic_interface_init (GdMainBoxGenericInterface *iface)
{
  iface->get_child_at_index = gd_main_icon_box_get_child_at_index;
  iface->get_last_selected_id = gd_main_icon_box_get_last_selected_id;
  iface->get_model = gd_main_icon_box_get_model;
  iface->get_selected_children = gd_main_icon_box_get_selected_children;
  iface->select_all = gd_main_icon_box_select_all_generic;
  iface->select_child = gd_main_icon_box_select_child;
  iface->unselect_all = gd_main_icon_box_unselect_all_generic;
  iface->unselect_child = gd_main_icon_box_unselect_child;
}

GtkWidget *
gd_main_icon_box_new (void)
{
  return g_object_new (GD_TYPE_MAIN_ICON_BOX, NULL);
}
