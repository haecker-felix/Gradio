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

#include "config.h"

#include "gd-margin-container.h"

G_DEFINE_TYPE_WITH_CODE (GdMarginContainer, gd_margin_container, GTK_TYPE_BIN,
                         G_IMPLEMENT_INTERFACE (GTK_TYPE_ORIENTABLE,
                                                NULL))

struct _GdMarginContainerPrivate {
  gint min_margin;
  gint max_margin;

  GtkOrientation orientation;
};

enum {
  PROP_MIN_MARGIN = 1,
  PROP_MAX_MARGIN,
  PROP_ORIENTATION,
  NUM_PROPERTIES
};

static void
gd_margin_container_queue_redraw (GdMarginContainer *self)
{
  GtkWidget *child;

  /* Make sure that the widget and children are redrawn with the new setting: */
  child = gtk_bin_get_child (GTK_BIN (self));
  if (child)
    gtk_widget_queue_resize (child);

  gtk_widget_queue_draw (GTK_WIDGET (self));
}

static void
gd_margin_container_set_orientation (GdMarginContainer *self,
                                     GtkOrientation orientation)
{
  if (self->priv->orientation != orientation)
    {
      self->priv->orientation = orientation;
      g_object_notify (G_OBJECT (self), "orientation");

      gd_margin_container_queue_redraw (self);
    }
}

static void
gd_margin_container_set_min_margin (GdMarginContainer *self,
                                    gint min_margin)
{
  if (self->priv->min_margin != min_margin)
    {
      self->priv->min_margin = min_margin;
      g_object_notify (G_OBJECT (self), "min-margin");

      gd_margin_container_queue_redraw (self);
    }
}

static void
gd_margin_container_set_max_margin (GdMarginContainer *self,
                                    gint max_margin)
{
  if (self->priv->max_margin != max_margin)
    {
      self->priv->max_margin = max_margin;
      g_object_notify (G_OBJECT (self), "max-margin");

      gd_margin_container_queue_redraw (self);
    }
}

static void
gd_margin_container_set_property (GObject      *object,
                                  guint         property_id,
                                  const GValue *value,
                                  GParamSpec   *pspec)
{
  GdMarginContainer *self = GD_MARGIN_CONTAINER (object);

  switch (property_id)
    {
    case PROP_MIN_MARGIN:
      gd_margin_container_set_min_margin (self, g_value_get_int (value));
      break;
    case PROP_MAX_MARGIN:
      gd_margin_container_set_max_margin (self, g_value_get_int (value));
      break;
    case PROP_ORIENTATION:
      gd_margin_container_set_orientation (self, g_value_get_enum (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_margin_container_get_property (GObject    *object,
                                  guint       property_id,
                                  GValue     *value,
                                  GParamSpec *pspec) 
{
  GdMarginContainer *self = GD_MARGIN_CONTAINER (object);

  switch (property_id)
    {
    case PROP_MIN_MARGIN: 
      g_value_set_int (value, self->priv->min_margin);
      break;
    case PROP_MAX_MARGIN:
      g_value_set_int (value, self->priv->max_margin);
      break;
    case PROP_ORIENTATION:
      g_value_set_enum (value, self->priv->orientation);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_margin_container_size_allocate (GtkWidget *widget,
                                   GtkAllocation *allocation)
{
  GdMarginContainer *self = GD_MARGIN_CONTAINER (widget);
  GtkWidget *child;
  GtkAllocation child_allocation;
  gint avail_width, avail_height;

  child = gtk_bin_get_child (GTK_BIN (widget));
  gtk_widget_set_allocation (widget, allocation);

  if (child && gtk_widget_get_visible (child))
    {
      gint child_nat_width;
      gint child_nat_height;
      gint child_width, child_height;
      gint offset;

      /* available */
      avail_width = allocation->width;
      avail_height = allocation->height;

      if (self->priv->orientation == GTK_ORIENTATION_HORIZONTAL)
        avail_width  = MAX (1, avail_width - 2 * self->priv->min_margin);
      else
        avail_height = MAX (1, avail_height - 2 * self->priv->min_margin);

      if (gtk_widget_get_request_mode (child) == GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH)
	{
	  gtk_widget_get_preferred_width (child, NULL, &child_nat_width);
	  child_width = MIN (avail_width, child_nat_width);

	  gtk_widget_get_preferred_height_for_width (child, child_width, NULL, &child_nat_height);
	  child_height = MIN (avail_height, child_nat_height);

          offset = MIN ((gint) ((avail_height - child_height) / 2), self->priv->max_margin);

          if (offset > 0)
            child_allocation.height = avail_height  - (offset * 2);
          else
            child_allocation.height = avail_height;

          child_allocation.width = MIN (avail_width, child_nat_width);
	}
      else
	{
	  gtk_widget_get_preferred_height (child, NULL, &child_nat_height);
	  child_height = MIN (avail_height, child_nat_height);

	  gtk_widget_get_preferred_width_for_height (child, child_height, NULL, &child_nat_width);
	  child_width = MIN (avail_width, child_nat_width);

          offset = MIN ((gint) ((avail_width - child_width) / 2), self->priv->max_margin);

          if (offset > 0)
            child_allocation.width = avail_width - (offset * 2);
          else
            child_allocation.width = avail_width;

          child_allocation.height = MIN (avail_height, child_nat_height);
	}

      child_allocation.x = offset + allocation->x;
      child_allocation.y = (avail_height - child_allocation.height) + allocation->y;

      if (self->priv->orientation == GTK_ORIENTATION_HORIZONTAL)
        child_allocation.x += self->priv->min_margin;
      else
        child_allocation.y += self->priv->min_margin;

      gtk_widget_size_allocate (child, &child_allocation);
    }
}

static void
gd_margin_container_get_preferred_size (GtkWidget *widget,
                                        GtkOrientation orientation,
                                        gint for_size,
                                        gint *minimum_size,
                                        gint *natural_size)
{
  GdMarginContainer *self = GD_MARGIN_CONTAINER (widget);
  guint natural, minimum;
  GtkWidget *child;

  if (orientation == self->priv->orientation)
    {
      minimum = self->priv->min_margin * 2;
      natural = self->priv->max_margin * 2;
    }
  else
    {
      minimum = 0;
      natural = 0;
    }

  if ((child = gtk_bin_get_child (GTK_BIN (widget))) && gtk_widget_get_visible (child))
    {
      gint child_min, child_nat;

      if (orientation == GTK_ORIENTATION_HORIZONTAL)
        {
	  if (for_size < 0)
	    gtk_widget_get_preferred_width (child, &child_min, &child_nat);
	  else
	    {
	      gint min_height;

	      gtk_widget_get_preferred_height (child, &min_height, NULL);
	      for_size -= 2 * self->priv->min_margin;

	      gtk_widget_get_preferred_width_for_height (child, for_size, &child_min, &child_nat);
	    }
        }
      else
        {
	  if (for_size < 0)
	    gtk_widget_get_preferred_height (child, &child_min, &child_nat);
	  else
	    {
	      gint min_width;

	      gtk_widget_get_preferred_width (child, &min_width, NULL);
	      for_size -= 2 * self->priv->min_margin;

	      gtk_widget_get_preferred_height_for_width (child, for_size, &child_min, &child_nat);
	    }
        }

      natural += child_nat;

      if (orientation != self->priv->orientation)
        minimum += child_min;
    }

  if (minimum_size != NULL)
    *minimum_size = minimum;
  if (natural_size != NULL)
    *natural_size = natural;
}

static void
gd_margin_container_get_preferred_width (GtkWidget *widget,
                                         gint      *minimum_size,
                                         gint      *natural_size)
{
  gd_margin_container_get_preferred_size (widget, GTK_ORIENTATION_HORIZONTAL,
                                          -1, minimum_size, natural_size);
}

static void
gd_margin_container_get_preferred_height (GtkWidget *widget,
                                          gint      *minimum_size,
                                          gint      *natural_size)
{
  gd_margin_container_get_preferred_size (widget, GTK_ORIENTATION_VERTICAL,
                                          -1, minimum_size, natural_size);
}

static void 
gd_margin_container_get_preferred_width_for_height (GtkWidget *widget,
                                                    gint       for_size,
                                                    gint      *minimum_size,
                                                    gint      *natural_size)
{
  gd_margin_container_get_preferred_size (widget, GTK_ORIENTATION_HORIZONTAL,
                                          for_size, minimum_size, natural_size);
}

static void 
gd_margin_container_get_preferred_height_for_width (GtkWidget *widget,
                                                    gint       for_size,
                                                    gint      *minimum_size,
                                                    gint      *natural_size)
{
  gd_margin_container_get_preferred_size (widget, GTK_ORIENTATION_VERTICAL,
                                          for_size, minimum_size, natural_size);
}

static void
gd_margin_container_init (GdMarginContainer *self)
{
  self->priv = G_TYPE_INSTANCE_GET_PRIVATE (self, GD_TYPE_MARGIN_CONTAINER,
                                            GdMarginContainerPrivate);

  self->priv->orientation = GTK_ORIENTATION_HORIZONTAL;

  gtk_widget_set_has_window (GTK_WIDGET (self), FALSE);
  gtk_widget_set_redraw_on_allocate (GTK_WIDGET (self), FALSE);
}

static void
gd_margin_container_class_init (GdMarginContainerClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);
  GtkWidgetClass *wclass = GTK_WIDGET_CLASS (klass);

  oclass->get_property = gd_margin_container_get_property;
  oclass->set_property = gd_margin_container_set_property;

  wclass->size_allocate = gd_margin_container_size_allocate;
  wclass->get_preferred_width = gd_margin_container_get_preferred_width;
  wclass->get_preferred_height = gd_margin_container_get_preferred_height;
  wclass->get_preferred_width_for_height = gd_margin_container_get_preferred_width_for_height;
  wclass->get_preferred_height_for_width = gd_margin_container_get_preferred_height_for_width;

  gtk_container_class_handle_border_width (GTK_CONTAINER_CLASS (klass));

  g_object_class_install_property (oclass, PROP_MIN_MARGIN,
                                   g_param_spec_int ("min-margin",
                                                     "Min margin",
                                                     "Minimum margin around the child",
                                                     0, G_MAXINT, 6,
                                                     G_PARAM_READWRITE |
                                                     G_PARAM_CONSTRUCT));
  g_object_class_install_property (oclass, PROP_MAX_MARGIN,
                                   g_param_spec_int ("max-margin",
                                                     "Max margin",
                                                     "Maximum margin around the child",
                                                     0, G_MAXINT, 6,
                                                     G_PARAM_READWRITE |
                                                     G_PARAM_CONSTRUCT));
  g_object_class_override_property (oclass, PROP_ORIENTATION,
                                    "orientation");
;
  g_type_class_add_private (klass, sizeof (GdMarginContainerPrivate));
}

GdMarginContainer *
gd_margin_container_new (void)
{
  return g_object_new (GD_TYPE_MARGIN_CONTAINER, NULL);
}
