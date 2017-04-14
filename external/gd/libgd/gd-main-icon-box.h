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

#ifndef __GD_MAIN_ICON_BOX_H__
#define __GD_MAIN_ICON_BOX_H__

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define GD_TYPE_MAIN_ICON_BOX gd_main_icon_box_get_type()
G_DECLARE_DERIVABLE_TYPE (GdMainIconBox, gd_main_icon_box, GD, MAIN_ICON_BOX, GtkFlowBox)

struct _GdMainIconBoxClass
{
  GtkFlowBoxClass parent_class;

  /* signals */
  gboolean  (* move_cursor)            (GdMainIconBox *self, GtkMovementStep step, gint count);
};

GtkWidget * gd_main_icon_box_new (void);

G_END_DECLS

#endif /* __GD_MAIN_ICON_BOX_H__ */
