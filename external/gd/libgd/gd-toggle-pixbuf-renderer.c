/*
 * Copyright (c) 2011 Red Hat, Inc.
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
 * Author: Cosimo Cecchi <cosimoc@redhat.com>
 *
 */

#include "gd-toggle-pixbuf-renderer.h"

G_DEFINE_TYPE (GdTogglePixbufRenderer, gd_toggle_pixbuf_renderer, GTK_TYPE_CELL_RENDERER_PIXBUF);

enum {
  PROP_ACTIVE = 1,
  PROP_TOGGLE_VISIBLE,
  PROP_PULSE,
  NUM_PROPERTIES
};

static GParamSpec *properties[NUM_PROPERTIES] = { NULL, };

struct _GdTogglePixbufRendererPrivate {
  gboolean active;
  gboolean toggle_visible;

  guint pulse;
};

static void
render_check (GdTogglePixbufRenderer *self,
              cairo_t                *cr,
              GtkWidget              *widget,
              const GdkRectangle     *cell_area,
              gint                    icon_size,
              gint                    xpad,
              gint                    ypad)
{
  GtkStyleContext *context;
  gint check_x, check_y, x_offset;
  GtkTextDirection direction;

  context = gtk_widget_get_style_context (widget);

  if (!self->priv->toggle_visible)
    return;

  direction = gtk_widget_get_direction (widget);
  if (direction == GTK_TEXT_DIR_RTL)
    x_offset = xpad;
  else
    x_offset = cell_area->width - icon_size - xpad;

  check_x = cell_area->x + x_offset;
  check_y = cell_area->y + cell_area->height - icon_size - ypad;

  gtk_style_context_save (context);
  gtk_style_context_add_class (context, GTK_STYLE_CLASS_CHECK);

  if (self->priv->active)
    gtk_style_context_set_state (context, gtk_widget_get_state_flags (widget) | GTK_STATE_FLAG_CHECKED);

  gtk_render_background (context, cr,
                         check_x, check_y,
                         icon_size, icon_size);
  gtk_render_frame (context, cr,
                    check_x, check_y,
                    icon_size, icon_size);
  gtk_render_check (context, cr,
                    check_x, check_y,
                    icon_size, icon_size);
  gtk_style_context_restore (context);
}

static void
render_activity (GdTogglePixbufRenderer *self,
                 cairo_t                *cr,
                 GtkWidget              *widget,
                 const GdkRectangle     *cell_area,
                 gint                    icon_size,
                 gint                    xpad,
                 gint                    ypad)
{
  gint x, y, width, height;

  if (self->priv->pulse == 0)
    return;

  width = cell_area->width / 4;
  height = cell_area->height / 4;

  x = cell_area->x + (cell_area->width / 2) - (width / 2) - xpad;
  y = cell_area->y + (cell_area->height / 2) - (height / 2) - ypad;

  gtk_paint_spinner (gtk_widget_get_style (widget),
                     cr,
                     GTK_STATE_FLAG_ACTIVE,
                     widget,
                     NULL,
                     (guint) self->priv->pulse - 1,
                     x, y,
                     width, height);
}

static void
gd_toggle_pixbuf_renderer_render (GtkCellRenderer      *cell,
                                  cairo_t              *cr,
                                  GtkWidget            *widget,
                                  const GdkRectangle   *background_area,
                                  const GdkRectangle   *cell_area,
                                  GtkCellRendererState  flags)
{
  gint icon_size = -1;
  GdTogglePixbufRenderer *self = GD_TOGGLE_PIXBUF_RENDERER (cell);
  gint xpad, ypad;

  GTK_CELL_RENDERER_CLASS (gd_toggle_pixbuf_renderer_parent_class)->render
    (cell, cr, widget,
     background_area, cell_area, flags);

  gtk_cell_renderer_get_padding (cell, &xpad, &ypad);
  gtk_widget_style_get (widget,
                        "check-icon-size", &icon_size,
                        NULL);

  if (icon_size == -1)
    icon_size = 40;

  render_activity (self, cr, widget, cell_area, icon_size, xpad, ypad);
  render_check (self, cr, widget, cell_area, icon_size, xpad, ypad);
}

static void
gd_toggle_pixbuf_renderer_get_size (GtkCellRenderer *cell,
                                    GtkWidget       *widget,
                                    const GdkRectangle *cell_area,
                                    gint *x_offset,
                                    gint *y_offset,
                                    gint *width,
                                    gint *height)
{
  gint icon_size;

  gtk_widget_style_get (widget,
                        "check-icon-size", &icon_size,
                        NULL);

  GTK_CELL_RENDERER_CLASS (gd_toggle_pixbuf_renderer_parent_class)->get_size
    (cell, widget, cell_area,
     x_offset, y_offset, width, height);

  *width += icon_size / 4;
}

static void
gd_toggle_pixbuf_renderer_get_property (GObject    *object,
                                        guint       property_id,
                                        GValue     *value,
                                        GParamSpec *pspec)
{
  GdTogglePixbufRenderer *self = GD_TOGGLE_PIXBUF_RENDERER (object);

  switch (property_id)
    {
    case PROP_ACTIVE:
      g_value_set_boolean (value, self->priv->active);
      break;
    case PROP_TOGGLE_VISIBLE:
      g_value_set_boolean (value, self->priv->toggle_visible);
      break;
    case PROP_PULSE:
      g_value_set_uint (value, self->priv->pulse);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_toggle_pixbuf_renderer_set_property (GObject    *object,
                                        guint       property_id,
                                        const GValue *value,
                                        GParamSpec *pspec)
{
  GdTogglePixbufRenderer *self = GD_TOGGLE_PIXBUF_RENDERER (object);

  switch (property_id)
    {
    case PROP_ACTIVE:
      self->priv->active = g_value_get_boolean (value);
      break;
    case PROP_TOGGLE_VISIBLE:
      self->priv->toggle_visible = g_value_get_boolean (value);
      break;
    case PROP_PULSE:
      self->priv->pulse = g_value_get_uint (value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_toggle_pixbuf_renderer_class_init (GdTogglePixbufRendererClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);
  GtkCellRendererClass *crclass = GTK_CELL_RENDERER_CLASS (klass);

  crclass->render = gd_toggle_pixbuf_renderer_render;
  crclass->get_size = gd_toggle_pixbuf_renderer_get_size;
  oclass->get_property = gd_toggle_pixbuf_renderer_get_property;
  oclass->set_property = gd_toggle_pixbuf_renderer_set_property;

  properties[PROP_ACTIVE] = 
    g_param_spec_boolean ("active",
                          "Active",
                          "Whether the cell renderer is active",
                          FALSE,
                          G_PARAM_READWRITE |
                          G_PARAM_STATIC_STRINGS);
  properties[PROP_TOGGLE_VISIBLE] =
    g_param_spec_boolean ("toggle-visible",
                          "Toggle visible",
                          "Whether to draw the toggle indicator",
                          FALSE,
                          G_PARAM_READWRITE |
                          G_PARAM_STATIC_STRINGS);
  properties[PROP_PULSE] =
    g_param_spec_uint ("pulse",
		       "Pulse",
		       "Set to any value other than 0 to display a "
		       "spinner on top of the pixbuf.",
		       0,
		       G_MAXUINT,
		       0,
		       G_PARAM_READWRITE |
		       G_PARAM_STATIC_STRINGS);

  g_type_class_add_private (klass, sizeof (GdTogglePixbufRendererPrivate));
  g_object_class_install_properties (oclass, NUM_PROPERTIES, properties);
}

static void
gd_toggle_pixbuf_renderer_init (GdTogglePixbufRenderer *self)
{
  self->priv = G_TYPE_INSTANCE_GET_PRIVATE (self, GD_TYPE_TOGGLE_PIXBUF_RENDERER,
                                            GdTogglePixbufRendererPrivate);
  self->priv->pulse = 0;
}

GtkCellRenderer *
gd_toggle_pixbuf_renderer_new (void)
{
  return g_object_new (GD_TYPE_TOGGLE_PIXBUF_RENDERER, NULL);
}
