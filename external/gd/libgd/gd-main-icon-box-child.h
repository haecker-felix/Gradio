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

#ifndef __GD_MAIN_ICON_BOX_CHILD_H__
#define __GD_MAIN_ICON_BOX_CHILD_H__

#include <gtk/gtk.h>

#include "gd-main-box-item.h"

G_BEGIN_DECLS

#define GD_TYPE_MAIN_ICON_BOX_CHILD gd_main_icon_box_child_get_type()
G_DECLARE_DERIVABLE_TYPE (GdMainIconBoxChild, gd_main_icon_box_child, GD, MAIN_ICON_BOX_CHILD, GtkFlowBoxChild)

struct _GdMainIconBoxChildClass
{
  GtkFlowBoxChildClass parent_class;
};

GtkWidget * gd_main_icon_box_child_new (GdMainBoxItem *item, gboolean selection_mode);

G_END_DECLS

#endif /* __GD_MAIN_ICON_BOX_CHILD_H__ */
