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

#ifndef __GD_MAIN_BOX_ITEM_H__
#define __GD_MAIN_BOX_ITEM_H__

#include <cairo.h>
#include <glib-object.h>

G_BEGIN_DECLS

#define GD_TYPE_MAIN_BOX_ITEM gd_main_box_item_get_type()
G_DECLARE_INTERFACE (GdMainBoxItem, gd_main_box_item, GD, MAIN_BOX_ITEM, GObject)

struct _GdMainBoxItemInterface
{
  GTypeInterface base_iface;

  /* vtable */
  const gchar      * (* get_id)              (GdMainBoxItem *self);
  const gchar      * (* get_uri)             (GdMainBoxItem *self);
  const gchar      * (* get_primary_text)    (GdMainBoxItem *self);
  const gchar      * (* get_secondary_text)  (GdMainBoxItem *self);
  cairo_surface_t  * (* get_icon)            (GdMainBoxItem *self);
};

const gchar      * gd_main_box_item_get_id              (GdMainBoxItem *self);
const gchar      * gd_main_box_item_get_uri             (GdMainBoxItem *self);
const gchar      * gd_main_box_item_get_primary_text    (GdMainBoxItem *self);
const gchar      * gd_main_box_item_get_secondary_text  (GdMainBoxItem *self);
cairo_surface_t  * gd_main_box_item_get_icon            (GdMainBoxItem *self);
gint64             gd_main_box_item_get_mtime           (GdMainBoxItem *self);
gboolean           gd_main_box_item_get_pulse           (GdMainBoxItem *self);

G_END_DECLS

#endif /* __GD_MAIN_BOX_ITEM_H__ */
