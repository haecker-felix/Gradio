/*
 * Copyright (c) 2017 Red Hat, Inc.
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

#ifndef __GD_MAIN_ICON_BOX_ICON_H__
#define __GD_MAIN_ICON_BOX_ICON_H__

#include <gtk/gtk.h>

#include "gd-main-box-item.h"

G_BEGIN_DECLS

#define GD_TYPE_MAIN_ICON_BOX_ICON gd_main_icon_box_icon_get_type()
G_DECLARE_FINAL_TYPE (GdMainIconBoxIcon, gd_main_icon_box_icon, GD, MAIN_ICON_BOX_ICON, GtkDrawingArea)

GtkWidget        * gd_main_icon_box_icon_new          (GdMainBoxItem *item);
GdMainBoxItem    * gd_main_icon_box_icon_get_item     (GdMainIconBoxIcon *self);
void               gd_main_icon_box_icon_set_item     (GdMainIconBoxIcon *self, GdMainBoxItem *item);

G_END_DECLS

#endif /* __GD_MAIN_ICON_BOX_ICON_H__ */
