/* dzl-stack-list.c
 *
 * Copyright (C) 2015-2017 Christian Hergert <christian@hergert.me>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define G_LOG_DOMAIN "dzl-stack-list"

#include <glib/gi18n.h>

#include "dzl-animation.h"
#include "dzl-util-private.h"
#include "dzl-rect-helper.h"
#include "dzl-stack-list.h"

#define FADE_DURATION  250
#define SLIDE_DURATION 350

typedef struct
{
  GtkOverlay        *overlay;
  GtkScrolledWindow *scroller;
  GtkBox            *box;
  GtkListBox        *headers;
  GtkListBox        *content;
  GtkListBox        *fake_list;
  GtkStack          *flip_stack;

  GPtrArray         *models;

  GtkListBoxRow     *activated;

  GtkListBoxRow     *animating;
  DzlAnimation      *animation;
  DzlRectHelper     *animating_rect;
} DzlStackListPrivate;

typedef struct
{
  GListModel                    *model;
  GtkWidget                     *header;
  DzlStackListCreateWidgetFunc  create_widget_func;
  gpointer                       user_data;
  GDestroyNotify                 user_data_free_func;
} ModelInfo;

G_DEFINE_TYPE_WITH_PRIVATE (DzlStackList, dzl_stack_list, GTK_TYPE_BIN)

enum {
  PROP_0,
  PROP_MODEL,
  LAST_PROP
};

enum {
  HEADER_ACTIVATED,
  ROW_ACTIVATED,
  LAST_SIGNAL
};

static GParamSpec *properties [LAST_PROP];
static guint signals [LAST_SIGNAL];

static void
model_info_free (gpointer data)
{
  ModelInfo *info = data;

  g_object_unref (info->model);
  if (info->user_data_free_func)
    info->user_data_free_func (info->user_data);
  g_slice_free (ModelInfo, info);
}

static void
enable_activatable (GtkWidget *widget,
                    gpointer   user_data)
{
  GtkWidget **last = user_data;

  g_assert (GTK_IS_LIST_BOX_ROW (widget));
  g_assert (*last == NULL || GTK_IS_WIDGET (*last));

  gtk_list_box_row_set_activatable (GTK_LIST_BOX_ROW (widget), TRUE);
  *last = widget;
}

static void
dzl_stack_list_update_activatables (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  GtkWidget *last = NULL;

  g_assert (DZL_IS_STACK_LIST (self));

  gtk_container_foreach (GTK_CONTAINER (priv->headers),
                         enable_activatable,
                         &last);

  if (GTK_IS_LIST_BOX_ROW (last))
    gtk_list_box_row_set_activatable (GTK_LIST_BOX_ROW (last), FALSE);
}

static GtkWidget *
dzl_stack_list_create_widget_func (gpointer item,
                                   gpointer user_data)
{
  ModelInfo *info = user_data;

  return info->create_widget_func (item, info->user_data);
}

static void
dzl_stack_list_content_row_activated (DzlStackList  *self,
                                      GtkListBoxRow *row,
                                      GtkListBox    *box)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);

  g_return_if_fail (DZL_IS_STACK_LIST (self));
  g_return_if_fail (GTK_IS_LIST_BOX_ROW (row));
  g_return_if_fail (GTK_IS_LIST_BOX (box));

  priv->activated = row;

  g_signal_emit (self, signals [ROW_ACTIVATED], 0, row);

  priv->activated = NULL;
}

static void
dzl_stack_list_header_row_activated (DzlStackList  *self,
                                     GtkListBoxRow *row,
                                     GtkListBox    *box)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);

  g_return_if_fail (DZL_IS_STACK_LIST (self));
  g_return_if_fail (GTK_IS_LIST_BOX_ROW (row));
  g_return_if_fail (GTK_IS_LIST_BOX (box));

  priv->activated = row;

  g_signal_emit (self, signals [HEADER_ACTIVATED], 0, row);

  priv->activated = NULL;
}

static gboolean
dzl_stack_list__overlay__get_child_position (DzlStackList *self,
                                             GtkWidget    *widget,
                                             GdkRectangle *rect,
                                             GtkOverlay   *overlay)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  GtkRequisition min, nat;

  g_assert (DZL_IS_STACK_LIST (self));
  g_assert (GTK_IS_WIDGET (widget));
  g_assert (rect != NULL);
  g_assert (GTK_IS_OVERLAY (overlay));

  gtk_widget_get_preferred_size (widget, &min, &nat);

  dzl_rect_helper_get_rect (priv->animating_rect, rect);

  if (rect->width < min.width)
    rect->width = min.width;

  if (rect->height < min.height)
    rect->height = min.height;

  return TRUE;
}

static void
dzl_stack_list_scroll_to_top (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  GtkAdjustment *vadj;

  g_assert (DZL_IS_STACK_LIST (self));

  vadj = gtk_scrolled_window_get_vadjustment (priv->scroller);

  gtk_adjustment_set_value (vadj, 0.0);
}

static void
dzl_stack_list_end_anim (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  GtkListBoxRow *header;
  ModelInfo *info;

  g_assert (DZL_IS_STACK_LIST (self));
  g_assert (priv->animating != NULL);
  g_assert (priv->models->len > 0);

  info = g_ptr_array_index (priv->models, priv->models->len - 1);
  header = g_object_ref (priv->animating);

  priv->animating = NULL;

  if (priv->animation != NULL)
    {
      dzl_animation_stop (priv->animation);
      g_clear_object (&priv->animation);
    }

  g_assert (header != NULL);
  g_assert (GTK_IS_LIST_BOX_ROW (header));
  g_assert (gtk_widget_get_parent (GTK_WIDGET (header)) == GTK_WIDGET (priv->overlay));

  gtk_container_remove (GTK_CONTAINER (priv->overlay),
                        GTK_WIDGET (header));

  gtk_container_add (GTK_CONTAINER (priv->headers), GTK_WIDGET (header));

  gtk_list_box_bind_model (priv->content,
                           info->model,
                           dzl_stack_list_create_widget_func,
                           info,
                           NULL);

  dzl_stack_list_scroll_to_top (self);

  gtk_stack_set_visible_child (GTK_STACK (priv->flip_stack), GTK_WIDGET (priv->scroller));

  dzl_stack_list_update_activatables (self);

  g_object_notify_by_pspec (G_OBJECT (self), properties [PROP_MODEL]);

  g_object_unref (header);
}

static void
animation_finished (gpointer data)
{
  DzlStackListPrivate *priv;
  DzlStackList *self;
  GtkListBoxRow *row;
  gpointer *closure = data;

  g_assert (closure != NULL);
  g_assert (DZL_IS_STACK_LIST (closure [0]));
  g_assert (GTK_IS_LIST_BOX_ROW (closure [1]));

  self = closure [0];
  row = closure [1];

  priv = dzl_stack_list_get_instance_private (self);

  if (row == priv->animating)
    dzl_stack_list_end_anim (self);

  g_object_unref (closure[0]);
  g_object_unref (closure[1]);
  g_free (closure);
}

static void
dzl_stack_list_begin_anim (DzlStackList       *self,
                           GtkListBoxRow      *row,
                           const GdkRectangle *begin_area,
                           const GdkRectangle *end_area)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  GdkFrameClock *frame_clock;
  gpointer *closure;
  guint pos;
  guint duration = 0;

  g_assert (DZL_IS_STACK_LIST (self));
  g_assert (row != NULL);
  g_assert (begin_area != NULL);
  g_assert (end_area != NULL);

  priv->animating = row;

  g_object_set (priv->animating_rect,
                "x", begin_area->x,
                "y", begin_area->y,
                "width", begin_area->width,
                "height", begin_area->height,
                NULL);

  frame_clock = gtk_widget_get_frame_clock (GTK_WIDGET (self));

  closure = g_new0 (gpointer, 2);
  closure [0] = g_object_ref (self);
  closure [1] = g_object_ref_sink (row);

  gtk_overlay_add_overlay (GTK_OVERLAY (priv->overlay), GTK_WIDGET (row));

  pos = gtk_list_box_row_get_index (row);

  if (pos != 0)
    {
      guint distance = ABS (end_area->y - begin_area->y);

      duration = CLAMP (distance, 100, MAX (SLIDE_DURATION, distance / 5));
    }

  priv->animation = dzl_object_animate_full (priv->animating_rect,
                                              DZL_ANIMATION_EASE_OUT_CUBIC,
                                              duration,
                                              frame_clock,
                                              animation_finished,
                                              closure,
                                              "x", end_area->x,
                                              "y", end_area->y,
                                              "width", end_area->width,
                                              "height", end_area->height,
                                              NULL);

  g_object_ref (priv->animation);

  g_signal_connect_object (priv->animating_rect,
                           "notify",
                           G_CALLBACK (gtk_widget_queue_resize),
                           priv->animating,
                           G_CONNECT_SWAPPED);

  gtk_stack_set_visible_child (GTK_STACK (priv->flip_stack), GTK_WIDGET (priv->fake_list));
}

static void
dzl_stack_list_real_header_activated (DzlStackList  *self,
                                      GtkListBoxRow *header)
{
  gint pos;

  g_assert (DZL_IS_STACK_LIST (self));
  g_assert (GTK_IS_LIST_BOX_ROW (header));

  pos = gtk_list_box_row_get_index (header) + 1;

  while (dzl_stack_list_get_depth (self) > (guint)pos)
    dzl_stack_list_pop (self);
}

static void
dzl_stack_list_finalize (GObject *object)
{
  DzlStackList *self = (DzlStackList *)object;
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);

  g_clear_pointer (&priv->models, g_ptr_array_unref);
  g_clear_object (&priv->animating_rect);
  g_clear_object (&priv->animation);

  G_OBJECT_CLASS (dzl_stack_list_parent_class)->finalize (object);
}

static void
dzl_stack_list_get_property (GObject    *object,
                             guint       prop_id,
                             GValue     *value,
                             GParamSpec *pspec)
{
  DzlStackList *self = DZL_STACK_LIST (object);

  switch (prop_id)
    {
    case PROP_MODEL:
      g_value_set_object (value, dzl_stack_list_get_model (self));
      break;

    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
    }
}

static void
dzl_stack_list_class_init (DzlStackListClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);

  object_class->finalize = dzl_stack_list_finalize;
  object_class->get_property = dzl_stack_list_get_property;

  klass->header_activated = dzl_stack_list_real_header_activated;

  properties [PROP_MODEL] =
    g_param_spec_object ("model",
                         _("Model"),
                         _("Model"),
                         G_TYPE_LIST_MODEL,
                         (G_PARAM_READABLE | G_PARAM_STATIC_STRINGS));

  g_object_class_install_properties (object_class, LAST_PROP, properties);

  signals [HEADER_ACTIVATED] =
    g_signal_new ("header-activated",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  G_STRUCT_OFFSET (DzlStackListClass, header_activated),
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  1,
                  GTK_TYPE_LIST_BOX_ROW);

  signals [ROW_ACTIVATED] =
    g_signal_new ("row-activated",
                  G_TYPE_FROM_CLASS (klass),
                  G_SIGNAL_RUN_LAST,
                  G_STRUCT_OFFSET (DzlStackListClass, row_activated),
                  NULL, NULL, NULL,
                  G_TYPE_NONE,
                  1,
                  GTK_TYPE_LIST_BOX_ROW);

  gtk_widget_class_set_css_name (widget_class, "dzlstacklist");
}

static void
dzl_stack_list_init (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);

  priv->animating_rect = g_object_new (DZL_TYPE_RECT_HELPER, NULL);

  priv->models = g_ptr_array_new_with_free_func (model_info_free);

  priv->overlay = g_object_new (GTK_TYPE_OVERLAY,
                                "visible", TRUE,
                                NULL);
  g_signal_connect_object (priv->overlay,
                           "get-child-position",
                           G_CALLBACK (dzl_stack_list__overlay__get_child_position),
                           self,
                           G_CONNECT_SWAPPED);
  gtk_container_add (GTK_CONTAINER (self), GTK_WIDGET (priv->overlay));

  priv->box = g_object_new (GTK_TYPE_BOX,
                            "orientation", GTK_ORIENTATION_VERTICAL,
                            "vexpand", TRUE,
                            "visible", TRUE,
                            NULL);
  gtk_container_add (GTK_CONTAINER (priv->overlay), GTK_WIDGET (priv->box));

  priv->headers = g_object_new (GTK_TYPE_LIST_BOX,
                                "selection-mode", GTK_SELECTION_NONE,
                                "visible", TRUE,
                                NULL);
  g_signal_connect_object (priv->headers,
                           "row-activated",
                           G_CALLBACK (dzl_stack_list_header_row_activated),
                           self,
                           G_CONNECT_SWAPPED);
  gtk_style_context_add_class (gtk_widget_get_style_context (GTK_WIDGET (priv->headers)),
                               "stack-header");
  gtk_container_add (GTK_CONTAINER (priv->box), GTK_WIDGET (priv->headers));

  priv->flip_stack = g_object_new (GTK_TYPE_STACK,
                                   "transition-duration", FADE_DURATION,
                                   "transition-type", GTK_STACK_TRANSITION_TYPE_CROSSFADE,
                                   "visible", TRUE,
                                   "vexpand", TRUE,
                                   NULL);
  gtk_container_add (GTK_CONTAINER (priv->box), GTK_WIDGET (priv->flip_stack));

  priv->scroller = g_object_new (GTK_TYPE_SCROLLED_WINDOW,
                                 "shadow-type", GTK_SHADOW_NONE,
                                 "vexpand", TRUE,
                                 "visible", TRUE,
                                 NULL);
  gtk_container_add (GTK_CONTAINER (priv->flip_stack), GTK_WIDGET (priv->scroller));

  priv->content = g_object_new (GTK_TYPE_LIST_BOX,
                                "visible", TRUE,
                                NULL);
  gtk_style_context_add_class (gtk_widget_get_style_context (GTK_WIDGET (priv->content)),
                               "stack-children");
  g_signal_connect_object (priv->content,
                           "row-activated",
                           G_CALLBACK (dzl_stack_list_content_row_activated),
                           self,
                           G_CONNECT_SWAPPED);
  gtk_container_add (GTK_CONTAINER (priv->scroller), GTK_WIDGET (priv->content));

  priv->fake_list = g_object_new (GTK_TYPE_LIST_BOX,
                                  "visible", TRUE,
                                  NULL);
  gtk_container_add (GTK_CONTAINER (priv->flip_stack), GTK_WIDGET (priv->fake_list));
}

GtkWidget *
dzl_stack_list_new (void)
{
  return g_object_new (DZL_TYPE_STACK_LIST, NULL);
}

void
dzl_stack_list_push (DzlStackList                 *self,
                     GtkWidget                    *header,
                     GListModel                   *model,
                     DzlStackListCreateWidgetFunc  create_widget_func,
                     gpointer                      user_data,
                     GDestroyNotify                user_data_free_func)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  ModelInfo *info;
  GdkRectangle current_area;
  GdkRectangle target_area;
  gint nat_height;

  g_return_if_fail (DZL_IS_STACK_LIST (self));
  g_return_if_fail (GTK_IS_WIDGET (header));
  g_return_if_fail (G_IS_LIST_MODEL (model));
  g_return_if_fail (create_widget_func != NULL);

  if (priv->animating != NULL)
    dzl_stack_list_end_anim (self);

  if (!GTK_IS_LIST_BOX_ROW (header))
    header = g_object_new (GTK_TYPE_LIST_BOX_ROW,
                           "child", header,
                           "visible", TRUE,
                           NULL);

  info = g_slice_new0 (ModelInfo);
  info->header = header;
  info->model = g_object_ref (model);
  info->create_widget_func = create_widget_func;
  info->user_data = user_data;
  info->user_data_free_func = user_data_free_func;

  g_ptr_array_add (priv->models, info);

  /*
   * Nothing to animate, make everything happen immediately.
   */
  if (priv->activated == NULL)
    {
      gtk_container_add (GTK_CONTAINER (priv->headers), GTK_WIDGET (header));
      dzl_stack_list_update_activatables (self);
      gtk_list_box_bind_model (priv->content,
                               model,
                               dzl_stack_list_create_widget_func,
                               info,
                               NULL);
      dzl_stack_list_scroll_to_top (self);
      g_object_notify_by_pspec (G_OBJECT (self), properties [PROP_MODEL]);
      return;
    }

  /*
   * Get the location to begin the animation.
   */
  gtk_widget_get_allocation (GTK_WIDGET (priv->activated), &current_area);
  gtk_widget_translate_coordinates (GTK_WIDGET (priv->activated),
                                    GTK_WIDGET (priv->overlay),
                                    current_area.x, current_area.y,
                                    &current_area.x, &current_area.y);

  /*
   * Get the location to end the animation.
   */
  gtk_widget_get_allocation (GTK_WIDGET (priv->headers), &target_area);
  gtk_widget_get_preferred_height (GTK_WIDGET (header), NULL, &nat_height);
  target_area.y += target_area.height;
  target_area.height = nat_height;
  gtk_widget_translate_coordinates (GTK_WIDGET (header),
                                    GTK_WIDGET (priv->overlay),
                                    target_area.x, target_area.y,
                                    &target_area.x, &target_area.y);

  dzl_stack_list_begin_anim (self, GTK_LIST_BOX_ROW (header), &current_area, &target_area);
}

void
dzl_stack_list_pop (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  ModelInfo *info;

  g_return_if_fail (DZL_IS_STACK_LIST (self));

  if (priv->models->len == 0)
    return;

  if (priv->animating != NULL)
    dzl_stack_list_end_anim (self);

  info = g_ptr_array_index (priv->models, priv->models->len - 1);

  gtk_container_remove (GTK_CONTAINER (priv->headers), GTK_WIDGET (info->header));
  gtk_list_box_bind_model (priv->content, NULL, NULL, NULL, NULL);
  g_ptr_array_remove_index (priv->models, priv->models->len - 1);

  if (priv->models->len > 0)
    {
      info = g_ptr_array_index (priv->models, priv->models->len - 1);
      gtk_list_box_bind_model (priv->content,
                               info->model,
                               dzl_stack_list_create_widget_func,
                               info,
                               NULL);
    }

  dzl_stack_list_update_activatables (self);

  g_object_notify_by_pspec (G_OBJECT (self), properties [PROP_MODEL]);
}

/**
 * dzl_stack_list_get_model:
 *
 * Returns: (transfer none): An #DzlStackList.
 */
GListModel *
dzl_stack_list_get_model (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);
  ModelInfo *info;

  g_return_val_if_fail (DZL_IS_STACK_LIST (self), NULL);

  if (priv->models->len == 0)
    return NULL;

  info = g_ptr_array_index (priv->models, priv->models->len - 1);

  return info->model;
}

guint
dzl_stack_list_get_depth (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);

  g_return_val_if_fail (DZL_IS_STACK_LIST (self), 0);

  return priv->models->len;
}

void
dzl_stack_list_clear (DzlStackList *self)
{
  DzlStackListPrivate *priv = dzl_stack_list_get_instance_private (self);

  g_return_if_fail (DZL_IS_STACK_LIST (self));

  while (priv->models->len > 0)
    dzl_stack_list_pop (self);
}
