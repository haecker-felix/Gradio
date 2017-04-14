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

#include "gd-main-box-child.h"
#include "gd-main-icon-box-child.h"
#include "gd-main-icon-box-icon.h"

#include <gio/gio.h>
#include <glib.h>

typedef struct _GdMainIconBoxChildPrivate GdMainIconBoxChildPrivate;

struct _GdMainIconBoxChildPrivate
{
  GdMainBoxItem *item;
  GtkWidget *check_button;
  gboolean selection_mode;
  gboolean show_primary_text;
  gboolean show_secondary_text;
};

enum
{
  PROP_ITEM = 1,
  PROP_SELECTION_MODE,
  PROP_SHOW_PRIMARY_TEXT,
  PROP_SHOW_SECONDARY_TEXT,
  NUM_PROPERTIES
};

static void gd_main_box_child_interface_init (GdMainBoxChildInterface *iface);
G_DEFINE_TYPE_WITH_CODE (GdMainIconBoxChild, gd_main_icon_box_child, GTK_TYPE_FLOW_BOX_CHILD,
                         G_ADD_PRIVATE (GdMainIconBoxChild)
                         G_IMPLEMENT_INTERFACE (GD_TYPE_MAIN_BOX_CHILD, gd_main_box_child_interface_init))

static void
gd_main_icon_box_check_button_toggled (GdMainIconBoxChild *self)
{
  GdMainIconBoxChildPrivate *priv;
  GtkWidget *parent;

  priv = gd_main_icon_box_child_get_instance_private (self);

  parent = gtk_widget_get_parent (GTK_WIDGET (self));
  if (!GTK_IS_FLOW_BOX (parent))
    return;

  if (gtk_toggle_button_get_active (GTK_TOGGLE_BUTTON (priv->check_button)))
    gtk_flow_box_select_child (GTK_FLOW_BOX (parent), GTK_FLOW_BOX_CHILD (self));
  else
    gtk_flow_box_unselect_child (GTK_FLOW_BOX (parent), GTK_FLOW_BOX_CHILD (self));
}

static GdMainBoxItem *
gd_main_icon_box_child_get_item (GdMainBoxChild *child)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (child);
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);
  return priv->item;
}

static gint
gd_main_icon_box_child_get_index (GdMainBoxChild *child)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (child);
  gint index;

  index = gtk_flow_box_child_get_index (GTK_FLOW_BOX_CHILD (self));
  return index;
}

static gboolean
gd_main_icon_box_child_get_selected (GdMainBoxChild *child)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (child);
  gboolean selected;

  selected = gtk_flow_box_child_is_selected (GTK_FLOW_BOX_CHILD (self));
  return selected;
}

static gboolean
gd_main_icon_box_child_get_selection_mode (GdMainIconBoxChild *self)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);
  return priv->selection_mode;
}

static gboolean
gd_main_icon_box_child_get_show_primary_text (GdMainIconBoxChild *self)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);
  return priv->show_primary_text;
}

static gboolean
gd_main_icon_box_child_get_show_secondary_text (GdMainIconBoxChild *self)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);
  return priv->show_secondary_text;
}

static void
gd_main_icon_box_child_set_item (GdMainIconBoxChild *self, GdMainBoxItem *item)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);

  if (!g_set_object (&priv->item, item))
    return;

  g_object_notify (G_OBJECT (self), "item");
  gtk_widget_queue_draw (GTK_WIDGET (self));
}

static void
gd_main_icon_box_child_set_selected (GdMainBoxChild *child, gboolean selected)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (child);
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);
  gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (priv->check_button), selected);
}

static void
gd_main_icon_box_child_set_selection_mode (GdMainIconBoxChild *self, gboolean selection_mode)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);

  if (priv->selection_mode == selection_mode)
    return;

  priv->selection_mode = selection_mode;
  g_object_notify (G_OBJECT (self), "selection-mode");
  gtk_widget_queue_draw (GTK_WIDGET (self));
}

static void
gd_main_icon_box_child_update_layout (GdMainIconBoxChild *self)
{
  GdMainIconBoxChildPrivate *priv;
  GtkWidget *grid;
  GtkWidget *icon;
  GtkWidget *overlay;

  priv = gd_main_icon_box_child_get_instance_private (self);

  gtk_container_foreach (GTK_CONTAINER (self), (GtkCallback) gtk_widget_destroy, NULL);

  grid = gtk_grid_new ();
  gtk_widget_set_valign (grid, GTK_ALIGN_CENTER);
  gtk_orientable_set_orientation (GTK_ORIENTABLE (grid), GTK_ORIENTATION_VERTICAL);
  gtk_container_add (GTK_CONTAINER (self), grid);

  overlay = gtk_overlay_new ();
  gtk_container_add (GTK_CONTAINER (grid), overlay);

  icon = gd_main_icon_box_icon_new (priv->item);
  gtk_widget_set_hexpand (icon, TRUE);
  gtk_container_add (GTK_CONTAINER (overlay), icon);

  priv->check_button = gtk_check_button_new ();
  gtk_widget_set_can_focus (priv->check_button, FALSE);
  gtk_widget_set_halign (priv->check_button, GTK_ALIGN_END);
  gtk_widget_set_valign (priv->check_button, GTK_ALIGN_END);
  gtk_widget_set_no_show_all (priv->check_button, TRUE);
  g_object_bind_property (self, "selection-mode", priv->check_button, "visible", G_BINDING_SYNC_CREATE);
  gtk_overlay_add_overlay (GTK_OVERLAY (overlay), priv->check_button);
  g_signal_connect_swapped (priv->check_button,
                            "toggled",
                            G_CALLBACK (gd_main_icon_box_check_button_toggled),
                            self);

  if (priv->show_primary_text)
    {
      GtkWidget *primary_label;

      primary_label = gtk_label_new (NULL);
      gtk_label_set_ellipsize (GTK_LABEL (primary_label), PANGO_ELLIPSIZE_MIDDLE);
      gtk_label_set_use_markup (GTK_LABEL (primary_label), TRUE);
      g_object_bind_property (priv->item, "primary-text", primary_label, "label", G_BINDING_SYNC_CREATE);
      gtk_container_add (GTK_CONTAINER (grid), primary_label);
    }

  if (priv->show_secondary_text)
    {
      GtkStyleContext *context;
      GtkWidget *secondary_label;

      secondary_label = gtk_label_new (NULL);
      gtk_label_set_ellipsize (GTK_LABEL (secondary_label), PANGO_ELLIPSIZE_END);
      gtk_label_set_use_markup (GTK_LABEL (secondary_label), TRUE);
      context = gtk_widget_get_style_context (secondary_label);
      gtk_style_context_add_class (context, "dim-label");
      g_object_bind_property (priv->item, "secondary-text", secondary_label, "label", G_BINDING_SYNC_CREATE);
      gtk_container_add (GTK_CONTAINER (grid), secondary_label);
    }

  gtk_widget_show_all (grid);
}

static void
gd_main_icon_box_child_set_show_primary_text (GdMainIconBoxChild *self, gboolean show_primary_text)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);

  if (priv->show_primary_text == show_primary_text)
    return;

  priv->show_primary_text = show_primary_text;
  gd_main_icon_box_child_update_layout (self);
  g_object_notify (G_OBJECT (self), "show-primary-text");
}

static void
gd_main_icon_box_child_set_show_secondary_text (GdMainIconBoxChild *self, gboolean show_secondary_text)
{
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);

  if (priv->show_secondary_text == show_secondary_text)
    return;

  priv->show_secondary_text = show_secondary_text;
  gd_main_icon_box_child_update_layout (self);
  g_object_notify (G_OBJECT (self), "show-secondary-text");
}

static void
gd_main_icon_box_child_constructed (GObject *obj)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (obj);

  G_OBJECT_CLASS (gd_main_icon_box_child_parent_class)->constructed (obj);

  gd_main_icon_box_child_update_layout (self);
}

static void
gd_main_icon_box_child_dispose (GObject *obj)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (obj);
  GdMainIconBoxChildPrivate *priv;

  priv = gd_main_icon_box_child_get_instance_private (self);

  g_clear_object (&priv->item);

  G_OBJECT_CLASS (gd_main_icon_box_child_parent_class)->dispose (obj);
}

static void
gd_main_icon_box_child_get_property (GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (object);

  switch (property_id)
    {
    case PROP_ITEM:
      g_value_set_object (value, gd_main_icon_box_child_get_item (GD_MAIN_BOX_CHILD (self)));
      break;
    case PROP_SELECTION_MODE:
      g_value_set_boolean (value, gd_main_icon_box_child_get_selection_mode (self));
      break;
    case PROP_SHOW_PRIMARY_TEXT:
      g_value_set_boolean (value, gd_main_icon_box_child_get_show_primary_text (self));
      break;
    case PROP_SHOW_SECONDARY_TEXT:
      g_value_set_boolean (value, gd_main_icon_box_child_get_show_secondary_text (self));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_icon_box_child_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec)
{
  GdMainIconBoxChild *self = GD_MAIN_ICON_BOX_CHILD (object);

  switch (property_id)
    {
    case PROP_ITEM:
      gd_main_icon_box_child_set_item (self, g_value_get_object (value));
      break;
    case PROP_SELECTION_MODE:
      gd_main_icon_box_child_set_selection_mode (self, g_value_get_boolean (value));
      break;
    case PROP_SHOW_PRIMARY_TEXT:
      gd_main_icon_box_child_set_show_primary_text (self, g_value_get_boolean (value));
      break;
    case PROP_SHOW_SECONDARY_TEXT:
      gd_main_icon_box_child_set_show_secondary_text (self, g_value_get_boolean (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_icon_box_child_init (GdMainIconBoxChild *self)
{
  GtkStyleContext *context;

  context = gtk_widget_get_style_context (GTK_WIDGET (self));
  gtk_style_context_add_class (context, "tile");
}

static void
gd_main_icon_box_child_class_init (GdMainIconBoxChildClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);

  oclass->constructed = gd_main_icon_box_child_constructed;
  oclass->dispose = gd_main_icon_box_child_dispose;
  oclass->get_property = gd_main_icon_box_child_get_property;
  oclass->set_property = gd_main_icon_box_child_set_property;

  g_object_class_override_property (oclass, PROP_ITEM, "item");
  g_object_class_override_property (oclass, PROP_SELECTION_MODE, "selection-mode");
  g_object_class_override_property (oclass, PROP_SHOW_PRIMARY_TEXT, "show-primary-text");
  g_object_class_override_property (oclass, PROP_SHOW_SECONDARY_TEXT, "show-secondary-text");
}

static void
gd_main_box_child_interface_init (GdMainBoxChildInterface *iface)
{
  iface->get_index = gd_main_icon_box_child_get_index;
  iface->get_item = gd_main_icon_box_child_get_item;
  iface->get_selected = gd_main_icon_box_child_get_selected;
  iface->set_selected = gd_main_icon_box_child_set_selected;
}

GtkWidget *
gd_main_icon_box_child_new (GdMainBoxItem *item, gboolean selection_mode)
{
  return g_object_new (GD_TYPE_MAIN_ICON_BOX_CHILD,
                       "item", item,
                       "selection-mode", selection_mode,
                       NULL);
}
