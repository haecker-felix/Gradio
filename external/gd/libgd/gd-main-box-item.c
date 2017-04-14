/*
 * Copyright (c) 2016 Red Hat, Inc.
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

#include <cairo-gobject.h>

#include "gd-main-box-item.h"

G_DEFINE_INTERFACE (GdMainBoxItem, gd_main_box_item, G_TYPE_OBJECT)

static void
gd_main_box_item_default_init (GdMainBoxItemInterface *iface)
{
  GParamSpec *pspec;

  /**
   * GdMainBoxItem:id:
   *
   * A unique ID to identify the #GdMainBoxItem object.
   */
  pspec = g_param_spec_string ("id",
                               "ID",
                               "A unique ID to identify the item",
                               NULL,
                               G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxItem:uri:
   *
   * A URI corresponding to the #GdMainBoxItem object.
   */
  pspec = g_param_spec_string ("uri",
                               "URI",
                               "A URI corresponding to the item",
                               NULL,
                               G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxItem:primary-text:
   *
   * Some text to describe the #GdMainBoxItem object.
   */
  pspec = g_param_spec_string ("primary-text",
                               "Primary Text",
                               "Some text to describe the item",
                               NULL,
                               G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxItem:secondary-text:
   *
   * Some additional text to describe the #GdMainBoxItem object.
   */
  pspec = g_param_spec_string ("secondary-text",
                               "Secondary Text",
                               "Some additional text to describe the item",
                               NULL,
                               G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxItem:icon:
   *
   * An icon to visually identify the #GdMainBoxItem object.
   */
  pspec = g_param_spec_boxed ("icon",
                              "Icon",
                              "An icon to visually identify the item",
                              CAIRO_GOBJECT_TYPE_SURFACE,
                              G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxItem:mtime:
   *
   * The time when the #GdMainBoxItem object was last modified.
   */
  pspec = g_param_spec_int64 ("mtime",
                              "Modification time",
                              "The time when the item was last modified",
                              -1,
                              G_MAXINT64,
                              -1,
                              G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxItem:pulse:
   *
   * Whether to show a progress indicator.
   */
  pspec = g_param_spec_boolean ("pulse",
                                "Pulse",
                                "Whether to show a progress indicator",
                                FALSE,
                                G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);
}

/**
 * gd_main_box_item_get_id:
 * @self:
 *
 * Returns: (transfer none): The ID
 */
const gchar *
gd_main_box_item_get_id (GdMainBoxItem *self)
{
  GdMainBoxItemInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), NULL);

  iface = GD_MAIN_BOX_ITEM_GET_IFACE (self);

  return (* iface->get_id) (self);
}

/**
 * gd_main_box_item_get_uri:
 * @self:
 *
 * Returns: (transfer none): The URI
 */
const gchar *
gd_main_box_item_get_uri (GdMainBoxItem *self)
{
  GdMainBoxItemInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), NULL);

  iface = GD_MAIN_BOX_ITEM_GET_IFACE (self);

  return (* iface->get_uri) (self);
}

/**
 * gd_main_box_item_get_primary_text:
 * @self:
 *
 * Returns: (transfer none): The primary text
 */
const gchar *
gd_main_box_item_get_primary_text (GdMainBoxItem *self)
{
  GdMainBoxItemInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), NULL);

  iface = GD_MAIN_BOX_ITEM_GET_IFACE (self);

  return (* iface->get_primary_text) (self);
}

/**
 * gd_main_box_item_get_secondary_text:
 * @self:
 *
 * Returns: (transfer none): The secondary text
 */
const gchar *
gd_main_box_item_get_secondary_text (GdMainBoxItem *self)
{
  GdMainBoxItemInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), NULL);

  iface = GD_MAIN_BOX_ITEM_GET_IFACE (self);

  return (* iface->get_secondary_text) (self);
}

/**
 * gd_main_box_item_get_icon:
 * @self:
 *
 * Returns: (transfer none): The icon
 */
cairo_surface_t *
gd_main_box_item_get_icon (GdMainBoxItem *self)
{
  GdMainBoxItemInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), NULL);

  iface = GD_MAIN_BOX_ITEM_GET_IFACE (self);

  return (* iface->get_icon) (self);
}

/**
 * gd_main_box_item_get_mtime:
 * @self:
 *
 * Returns: (transfer none): The modification time
 */
gint64
gd_main_box_item_get_mtime (GdMainBoxItem *self)
{
  gint64 mtime;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), -1);

  g_object_get (self, "mtime", &mtime, NULL);
  return mtime;
}

/**
 * gd_main_box_item_get_pulse:
 * @self:
 *
 * Returns: (transfer none): Whether to show a progress indicator
 */
gboolean
gd_main_box_item_get_pulse (GdMainBoxItem *self)
{
  gboolean pulse;

  g_return_val_if_fail (GD_IS_MAIN_BOX_ITEM (self), FALSE);

  g_object_get (self, "pulse", &pulse, NULL);
  return pulse;
}
