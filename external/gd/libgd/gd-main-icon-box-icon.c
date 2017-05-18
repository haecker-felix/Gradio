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

#include "gd-main-icon-box-icon.h"

#include <cairo.h>
#include <glib.h>

struct _GdMainIconBoxIcon
{
  GtkDrawingArea parent_instance;
  GdMainBoxItem *item;
  cairo_surface_t *surface_zoomed;
  gdouble x;
  gdouble y;
};

enum
{
  PROP_ITEM = 1,
  NUM_PROPERTIES
};

static GParamSpec *properties[NUM_PROPERTIES] = { NULL, };

G_DEFINE_TYPE (GdMainIconBoxIcon, gd_main_icon_box_icon, GTK_TYPE_DRAWING_AREA)

static cairo_surface_t *
gd_zoom_image_surface (cairo_surface_t *surface, gint width_zoomed, gint height_zoomed)
{
  cairo_t *cr;
  cairo_format_t format;
  cairo_pattern_t *pattern;
  cairo_surface_t *zoomed = NULL;
  cairo_surface_type_t surface_type;
  gdouble scale_x;
  gdouble scale_y;
  gdouble zoom_x;
  gdouble zoom_y;
  gint height;
  gint width;

  g_return_val_if_fail (surface != NULL, NULL);

  surface_type = cairo_surface_get_type (surface);
  g_return_val_if_fail (surface_type == CAIRO_SURFACE_TYPE_IMAGE, NULL);

  format = cairo_image_surface_get_format (surface);
  zoomed = cairo_surface_create_similar_image (surface, format, width_zoomed, height_zoomed);
  cairo_surface_get_device_scale (surface, &scale_x, &scale_y);
  cairo_surface_set_device_scale (zoomed, scale_x, scale_y);

  cr = cairo_create (zoomed);

  pattern = cairo_get_source (cr);
  cairo_pattern_set_extend (pattern, CAIRO_EXTEND_REFLECT);
  cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);

  height = cairo_image_surface_get_height (surface);
  width = cairo_image_surface_get_width (surface);
  zoom_x = (double) width_zoomed / (gdouble) width;
  zoom_y = (double) height_zoomed / (gdouble) height;
  cairo_scale (cr, zoom_x, zoom_y);
  cairo_set_source_surface (cr, surface, 0, 0);

  cairo_paint (cr);
  cairo_destroy (cr);

  return zoomed;
}

static void
gd_main_icon_box_icon_get_preferred_size (GdMainIconBoxIcon *self, gint *minimum, gint *natural)
{
  cairo_surface_t *surface;
  cairo_surface_type_t surface_type;
  gint height_scaled;
  gint width_scaled;
  gint scale_factor;
  gint size = 0;
  gint size_scaled;

  surface = gd_main_box_item_get_icon (self->item);
  if (surface == NULL)
    goto out;

  surface_type = cairo_surface_get_type (surface);
  g_return_if_fail (surface_type == CAIRO_SURFACE_TYPE_IMAGE);

  scale_factor = gtk_widget_get_scale_factor (GTK_WIDGET (self));
  height_scaled = cairo_image_surface_get_height (surface);
  width_scaled = cairo_image_surface_get_width (surface);

  size_scaled = MAX (height_scaled, width_scaled);
  size = size_scaled / scale_factor;

 out:
  if (minimum != NULL)
    *minimum = size;

  if (natural != NULL)
    *natural = size;
}

static void
gd_main_icon_box_icon_notify_icon (GdMainIconBoxIcon *self)
{
  g_clear_pointer (&self->surface_zoomed, (GDestroyNotify) cairo_surface_destroy);
  gtk_widget_queue_resize (GTK_WIDGET (self));
}

static gboolean
gd_main_icon_box_icon_draw (GtkWidget *widget, cairo_t *cr)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (widget);

  if (self->surface_zoomed == NULL)
    goto out;

  cairo_save (cr);
  cairo_set_source_surface (cr, self->surface_zoomed, self->x, self->y);
  cairo_paint (cr);
  cairo_restore (cr);

 out:
  return GDK_EVENT_PROPAGATE;
}

static void
gd_main_icon_box_icon_get_preferred_height (GtkWidget *widget, gint *minimum, gint *natural)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (widget);
  gd_main_icon_box_icon_get_preferred_size (self, minimum, natural);
}

static void
gd_main_icon_box_icon_get_preferred_width (GtkWidget *widget, gint *minimum, gint *natural)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (widget);
  gd_main_icon_box_icon_get_preferred_size (self, minimum, natural);
}

static void
gd_main_icon_box_icon_size_allocate (GtkWidget *widget, GtkAllocation *allocation)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (widget);
  cairo_surface_t *surface;
  cairo_surface_type_t surface_type;
  gdouble zoom;
  gint allocation_height_scaled;
  gint allocation_width_scaled;
  gint height_scaled;
  gint height_zoomed_scaled;
  gint scale_factor;
  gint width_scaled;
  gint width_zoomed_scaled;
  gint x_scaled;
  gint y_scaled;

  GTK_WIDGET_CLASS (gd_main_icon_box_icon_parent_class)->size_allocate (widget, allocation);

  surface = gd_main_box_item_get_icon (self->item);
  if (surface == NULL)
    {
      g_return_if_fail (self->surface_zoomed == NULL);
      return;
    }

  surface_type = cairo_surface_get_type (surface);
  g_return_if_fail (surface_type == CAIRO_SURFACE_TYPE_IMAGE);

  scale_factor = gtk_widget_get_scale_factor (GTK_WIDGET (self));

  allocation_height_scaled = allocation->height * scale_factor;
  allocation_width_scaled = allocation->width * scale_factor;

  if (self->surface_zoomed != NULL)
    {
      height_zoomed_scaled = cairo_image_surface_get_height (self->surface_zoomed);
      width_zoomed_scaled = cairo_image_surface_get_width (self->surface_zoomed);
      if (height_zoomed_scaled == allocation_height_scaled && width_zoomed_scaled == allocation_width_scaled)
        return;
    }

  height_scaled = cairo_image_surface_get_height (surface);
  width_scaled = cairo_image_surface_get_width (surface);

  if (height_scaled > width_scaled && allocation_height_scaled > height_scaled)
    {
      zoom = (gdouble) allocation_height_scaled / (gdouble) height_scaled;
      height_zoomed_scaled = allocation_height_scaled;
      width_zoomed_scaled = (gint) (zoom * (gdouble) width_scaled + 0.5);

      if (allocation_width_scaled < width_zoomed_scaled)
        {
          zoom = (gdouble) allocation_width_scaled / (gdouble) width_zoomed_scaled;
          height_zoomed_scaled = (gint) (zoom * (gdouble) height_zoomed_scaled + 0.5);
          width_zoomed_scaled = allocation_width_scaled;
        }
    }
  else if (height_scaled <= width_scaled && allocation_width_scaled > width_scaled)
    {
      zoom = (gdouble) allocation_width_scaled / (gdouble) width_scaled;
      height_zoomed_scaled = (gint) (zoom * (gdouble) height_scaled + 0.5);
      width_zoomed_scaled = allocation_width_scaled;

      if (allocation_height_scaled < height_zoomed_scaled)
        {
          zoom = (gdouble) allocation_height_scaled / (gdouble) height_zoomed_scaled;
          height_zoomed_scaled = allocation_height_scaled;
          width_zoomed_scaled = (gint) (zoom * (gdouble) width_zoomed_scaled + 0.5);
        }
    }
  else
    {
      height_zoomed_scaled = height_scaled;
      width_zoomed_scaled = width_scaled;
    }

  g_clear_pointer (&self->surface_zoomed, (GDestroyNotify) cairo_surface_destroy);
  self->surface_zoomed = gd_zoom_image_surface (surface, width_zoomed_scaled, height_zoomed_scaled);

  self->x = (gdouble) (allocation_width_scaled - width_zoomed_scaled) / (2.0 * (gdouble) scale_factor);
  self->y = (gdouble) (allocation_height_scaled - height_zoomed_scaled) / (2.0 * (gdouble) scale_factor);
}

static void
gd_main_icon_box_icon_dispose (GObject *obj)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (obj);

  g_clear_object (&self->item);

  G_OBJECT_CLASS (gd_main_icon_box_icon_parent_class)->dispose (obj);
}

static void
gd_main_icon_box_icon_finalize (GObject *obj)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (obj);

  g_clear_pointer (&self->surface_zoomed, (GDestroyNotify) cairo_surface_destroy);

  G_OBJECT_CLASS (gd_main_icon_box_icon_parent_class)->finalize (obj);
}

static void
gd_main_icon_box_icon_get_property (GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (object);

  switch (property_id)
    {
    case PROP_ITEM:
      g_value_set_object (value, gd_main_icon_box_icon_get_item (self));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_icon_box_icon_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec)
{
  GdMainIconBoxIcon *self = GD_MAIN_ICON_BOX_ICON (object);

  switch (property_id)
    {
    case PROP_ITEM:
      gd_main_icon_box_icon_set_item (self, g_value_get_object (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_icon_box_icon_init (GdMainIconBoxIcon *self)
{
}

static void
gd_main_icon_box_icon_class_init (GdMainIconBoxIconClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);
  GtkWidgetClass *wclass = GTK_WIDGET_CLASS (klass);

  oclass->dispose = gd_main_icon_box_icon_dispose;
  oclass->finalize = gd_main_icon_box_icon_finalize;
  oclass->get_property = gd_main_icon_box_icon_get_property;
  oclass->set_property = gd_main_icon_box_icon_set_property;
  wclass->draw = gd_main_icon_box_icon_draw;
  wclass->get_preferred_height = gd_main_icon_box_icon_get_preferred_height;
  wclass->get_preferred_width = gd_main_icon_box_icon_get_preferred_width;
  wclass->size_allocate = gd_main_icon_box_icon_size_allocate;

  properties[PROP_ITEM] = g_param_spec_object ("item",
                                               "Item",
                                               "An item that is rendered by the widget",
                                               GD_TYPE_MAIN_BOX_ITEM,
                                               G_PARAM_EXPLICIT_NOTIFY |
                                               G_PARAM_READWRITE |
                                               G_PARAM_STATIC_STRINGS);

  g_object_class_install_properties (oclass, NUM_PROPERTIES, properties);
}

GtkWidget *
gd_main_icon_box_icon_new (GdMainBoxItem *item)
{
  g_return_val_if_fail (item == NULL || GD_IS_MAIN_BOX_ITEM (item), NULL);
  return g_object_new (GD_TYPE_MAIN_ICON_BOX_ICON, "item", item, NULL);
}

GdMainBoxItem *
gd_main_icon_box_icon_get_item (GdMainIconBoxIcon *self)
{
  g_return_val_if_fail (GD_IS_MAIN_ICON_BOX_ICON (self), NULL);
  return self->item;
}

void
gd_main_icon_box_icon_set_item (GdMainIconBoxIcon *self, GdMainBoxItem *item)
{
  g_return_if_fail (GD_IS_MAIN_ICON_BOX_ICON (self));
  g_return_if_fail (item == NULL || GD_IS_MAIN_BOX_ITEM (item));

  if (self->item == item)
    return;

  if (self->item != NULL)
    g_signal_handlers_disconnect_by_func (self->item, gd_main_icon_box_icon_notify_icon, self);

  g_clear_pointer (&self->surface_zoomed, (GDestroyNotify) cairo_surface_destroy);
  g_set_object (&self->item, item);

  if (self->item != NULL)
    {
      g_signal_connect_object (self->item,
                               "notify::icon",
                               G_CALLBACK (gd_main_icon_box_icon_notify_icon),
                               self,
                               G_CONNECT_SWAPPED);
    }

  g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_ITEM]);
  gtk_widget_queue_resize (GTK_WIDGET (self));
}
