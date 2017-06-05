/* dzl-rect-helper.h
 *
 * Copyright (C) 2015 Christian Hergert <christian@hergert.me>
 *
 * This file is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DZL_RECT_HELPER_H
#define DZL_RECT_HELPER_H

#include <gdk/gdk.h>

/*
 * This is just a helper object for animating rectangles.
 * It allows us to use dzl_object_animate() to animate
 * coordinates.
 */

G_BEGIN_DECLS

#define DZL_TYPE_RECT_HELPER (dzl_rect_helper_get_type())

G_DECLARE_FINAL_TYPE (DzlRectHelper, dzl_rect_helper, DZL, RECT_HELPER, GObject)

void dzl_rect_helper_get_rect (DzlRectHelper *self,
                               GdkRectangle  *rect);

G_END_DECLS

#endif /* DZL_RECT_HELPER_H */
