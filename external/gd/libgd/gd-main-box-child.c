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

G_DEFINE_INTERFACE (GdMainBoxChild, gd_main_box_child, GTK_TYPE_WIDGET)

static void
gd_main_box_child_default_init (GdMainBoxChildInterface *iface)
{
  GParamSpec *pspec;

  /**
   * GdMainBoxChild:item:
   *
   * A #GdMainBoxItem that is rendered by the #GdMainBoxChild widget.
   */
  pspec = g_param_spec_object ("item",
                               "Item",
                               "An item that is rendered by the widget",
                               GD_TYPE_MAIN_BOX_ITEM,
                               G_PARAM_CONSTRUCT_ONLY |
                               G_PARAM_EXPLICIT_NOTIFY |
                               G_PARAM_READWRITE |
                               G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxChild:selection-mode:
   *
   * Whether the #GdMainBoxChild widget is in selection mode.
   */
  pspec = g_param_spec_boolean ("selection-mode",
                                "Selection mode",
                                "Whether the child is in selection mode",
                                FALSE,
                                G_PARAM_CONSTRUCT |
                                G_PARAM_EXPLICIT_NOTIFY |
                                G_PARAM_READWRITE |
                                G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxChild:show-primary-text:
   *
   * Whether the #GdMainBoxChild widget is going to show the
   * primary-text of its item.
   */
  pspec = g_param_spec_boolean ("show-primary-text",
                                "Show Primary Text",
                                "Whether the item's primary-text is going to be shown",
                                FALSE,
                                G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxChild:show-secondary-text:
   *
   * Whether the #GdMainBoxChild widget is going to show the
   * secondary-text of its item.
   */
  pspec = g_param_spec_boolean ("show-secondary-text",
                                "Show Secondary Text",
                                "Whether the item's secondary-text is going to be shown",
                                FALSE,
                                G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);
}

/**
 * gd_main_box_child_get_item:
 * @self:
 *
 * Returns: (transfer none): The #GdMainBoxItem
 */
GdMainBoxItem *
gd_main_box_child_get_item (GdMainBoxChild *self)
{
  GdMainBoxChildInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_CHILD (self), NULL);

  iface = GD_MAIN_BOX_CHILD_GET_IFACE (self);

  return (* iface->get_item) (self);
}

/**
 * gd_main_box_child_get_index:
 * @self:
 *
 * Returns: (transfer none): The index
 */
gint
gd_main_box_child_get_index (GdMainBoxChild *self)
{
  GdMainBoxChildInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_CHILD (self), -1);

  iface = GD_MAIN_BOX_CHILD_GET_IFACE (self);

  return (* iface->get_index) (self);
}

/**
 * gd_main_box_child_get_selected:
 * @self:
 *
 * Returns: (transfer none): Whether @self is selected
 */
gboolean
gd_main_box_child_get_selected (GdMainBoxChild *self)
{
  GdMainBoxChildInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_CHILD (self), FALSE);

  iface = GD_MAIN_BOX_CHILD_GET_IFACE (self);

  return (* iface->get_selected) (self);
}

/**
 * gd_main_box_child_get_selection_mode:
 * @self:
 *
 * Returns: (transfer none): Whether @self is in selection mode
 */
gboolean
gd_main_box_child_get_selection_mode (GdMainBoxChild *self)
{
  gboolean selection_mode;

  g_return_val_if_fail (GD_IS_MAIN_BOX_CHILD (self), FALSE);

  g_object_get (self, "selection-mode", &selection_mode, NULL);
  return selection_mode;
}

/**
 * gd_main_box_child_set_selected:
 * @self:
 * @selected:
 */
void
gd_main_box_child_set_selected (GdMainBoxChild *self, gboolean selected)
{
  GdMainBoxChildInterface *iface;

  g_return_if_fail (GD_IS_MAIN_BOX_CHILD (self));

  iface = GD_MAIN_BOX_CHILD_GET_IFACE (self);

  return (* iface->set_selected) (self, selected);
}

/**
 * gd_main_box_child_set_selection_mode:
 * @self:
 * @selection_mode:
 */
void
gd_main_box_child_set_selection_mode  (GdMainBoxChild *self, gboolean selection_mode)
{
  g_return_if_fail (GD_IS_MAIN_BOX_CHILD (self));
  g_object_set (self, "selection-mode", selection_mode, NULL);
}
