/*
 * Copyright (c) 2016, 2017 Red Hat, Inc.
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

#include "gd-main-box-generic.h"
#include "gd-main-box-item.h"

enum
{
  ITEM_ACTIVATED,
  SELECTION_CHANGED,
  SELECTION_MODE_REQUEST,
  NUM_SIGNALS
};

static guint signals[NUM_SIGNALS] = { 0, };

G_DEFINE_INTERFACE (GdMainBoxGeneric, gd_main_box_generic, GTK_TYPE_WIDGET)

static void
gd_main_box_generic_mark_range_as_selected (GdMainBoxGeneric *self, gint first_element, gint last_element)
{
  gint i;

  if (first_element > last_element)
    {
      gint tmp;

      tmp = first_element;
      first_element = last_element;
      last_element = tmp;
    }

  for (i = first_element; i <= last_element; i++)
    {
      GdMainBoxChild *child;

      child = gd_main_box_generic_get_child_at_index (self, i);
      gd_main_box_generic_select_child (self, child);
    }
}

static void
gd_main_box_generic_select_range (GdMainBoxGeneric *self, GdMainBoxChild *child)
{
  GListModel *model;
  const gchar *last_selected_id;
  gint index;
  gint other_index = -1;
  guint n_items;

  model = gd_main_box_generic_get_model (self);
  n_items = g_list_model_get_n_items (model);

  last_selected_id = gd_main_box_generic_get_last_selected_id (self);
  index = gd_main_box_child_get_index (child);

  if (last_selected_id != NULL)
    {
      guint i;

      for (i = 0; i < n_items; i++)
        {
          GdMainBoxItem *item;
          const gchar *id;

          item = GD_MAIN_BOX_ITEM (g_list_model_get_object (model, i));
          id = gd_main_box_item_get_id (item);

	  if (g_strcmp0 (id, last_selected_id) == 0)
            {
              other_index = (gint) i;
              g_object_unref (item);
              break;
            }

          g_object_unref (item);
	}
    }

  if (other_index == -1)
    {
      gint i;

      for (i = index - 1; i >= 0; i--)
        {
          GdMainBoxChild *other;

          other = gd_main_box_generic_get_child_at_index (self, i);
          if (gd_main_box_child_get_selected (other))
            {
              other_index = i;
              break;
	    }
	}
    }

  if (other_index == -1)
    {
      gint i;

      for (i = index + 1; i < (gint) n_items; i++)
        {
          GdMainBoxChild *other;

          other = gd_main_box_generic_get_child_at_index (self, i);
          if (gd_main_box_child_get_selected (other))
            {
              other_index = i;
              break;
            }
        }
    }

  if (other_index == -1)
    gd_main_box_generic_select_child (self, child);
  else
    gd_main_box_generic_mark_range_as_selected (self, index, other_index);
}

static void
gd_main_box_generic_default_init (GdMainBoxGenericInterface *iface)
{
  GParamSpec *pspec;

  /**
   * GdMainBoxGeneric:last-selected-id:
   *
   * A unique ID to identify the #GdMainBoxItem object that was most
   * recently selected.
   */
  pspec = g_param_spec_string ("last-selected-id",
                               "ID",
                               "A unique ID to identify the most recently selected item",
                               NULL,
                               G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READABLE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxGeneric:model:
   *
   * A #GListModel that is rendered by the #GdMainBoxGeneric widget.
   */
  pspec = g_param_spec_object ("model",
                               "Model",
                               "A model that is rendered by the widget",
                               G_TYPE_LIST_MODEL,
                               G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxGeneric:gd-selection-mode:
   *
   * Whether the #GdMainBoxGeneric widget is in selection mode.
   */
  pspec = g_param_spec_boolean ("gd-selection-mode",
                                "Selection Mode",
                                "Whether the widget is in selection mode",
                                FALSE,
                                G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxGeneric:show-primary-text:
   *
   * Whether the #GdMainBoxGeneric widget is going to show the
   * primary-text of each #GdMainBoxItem.
   */
  pspec = g_param_spec_boolean ("show-primary-text",
                                "Show Primary Text",
                                "Whether each GdMainBoxItem's primary-text is going to be shown",
                                FALSE,
                                G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  /**
   * GdMainBoxGeneric:show-secondary-text:
   *
   * Whether the #GdMainBoxGeneric widget is going to show the
   * secondary-text of each #GdMainBoxItem.
   */
  pspec = g_param_spec_boolean ("show-secondary-text",
                                "Show Secondary Text",
                                "Whether each GdMainBoxItem's secondary-text is going to be shown",
                                FALSE,
                                G_PARAM_EXPLICIT_NOTIFY | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
  g_object_interface_install_property (iface, pspec);

  signals[ITEM_ACTIVATED] = g_signal_new ("item-activated",
                                          GD_TYPE_MAIN_BOX_GENERIC,
                                          G_SIGNAL_RUN_LAST,
                                          0,
                                          NULL,
                                          NULL,
                                          g_cclosure_marshal_VOID__OBJECT,
                                          G_TYPE_NONE,
                                          1,
                                          GD_TYPE_MAIN_BOX_CHILD);

  signals[SELECTION_CHANGED] = g_signal_new ("selection-changed",
                                             GD_TYPE_MAIN_BOX_GENERIC,
                                             G_SIGNAL_RUN_LAST,
                                             0,
                                             NULL,
                                             NULL,
                                             g_cclosure_marshal_VOID__VOID,
                                             G_TYPE_NONE,
                                             0);

  signals[SELECTION_MODE_REQUEST] = g_signal_new ("selection-mode-request",
                                                  GD_TYPE_MAIN_BOX_GENERIC,
                                                  G_SIGNAL_RUN_LAST,
                                                  0,
                                                  NULL,
                                                  NULL,
                                                  g_cclosure_marshal_VOID__VOID,
                                                  G_TYPE_NONE,
                                                  0);
}

/**
 * gd_main_box_generic_get_child_at_index:
 * @self:
 * @index:
 *
 * Returns: (transfer none): The child at @index.
 */
GdMainBoxChild *
gd_main_box_generic_get_child_at_index (GdMainBoxGeneric *self, gint index)
{
  GdMainBoxGenericInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), NULL);

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  return (* iface->get_child_at_index) (self, index);
}

/**
 * gd_main_box_generic_get_last_selected_id:
 * @self:
 *
 * Returns: (transfer none): The ID of the most recently selected #GdMainBoxItem.
 */
const gchar *
gd_main_box_generic_get_last_selected_id (GdMainBoxGeneric *self)
{
  GdMainBoxGenericInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), NULL);

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  return (* iface->get_last_selected_id) (self);
}

/**
 * gd_main_box_generic_get_model:
 * @self:
 *
 * Returns: (transfer none): The associated model
 */
GListModel *
gd_main_box_generic_get_model (GdMainBoxGeneric *self)
{
  GdMainBoxGenericInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), NULL);

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  return (* iface->get_model) (self);
}

/**
 * gd_main_box_generic_get_selected_children:
 * @self:
 *
 * Returns: (element-type GdMainBoxChild) (transfer container): The
 * selected children
 */
GList *
gd_main_box_generic_get_selected_children (GdMainBoxGeneric *self)
{
  GdMainBoxGenericInterface *iface;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), NULL);

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  return (* iface->get_selected_children) (self);
}

/**
 * gd_main_box_generic_get_selection_mode:
 * @self:
 *
 * Returns: (transfer none): Whether @self is in selection mode
 */
gboolean
gd_main_box_generic_get_selection_mode (GdMainBoxGeneric *self)
{
  gboolean selection_mode;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), FALSE);

  g_object_get (self, "gd-selection-mode", &selection_mode, NULL);
  return selection_mode;
}

/**
 * gd_main_box_generic_get_show_primary_text:
 * @self:
 *
 * Returns: (transfer none): Whether @self is going to show the
 * primary-text of each #GdMainBoxItem
 */
gboolean
gd_main_box_generic_get_show_primary_text (GdMainBoxGeneric *self)
{
  gboolean show_primary_text;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), FALSE);

  g_object_get (self, "show-primary-text", &show_primary_text, NULL);
  return show_primary_text;
}

/**
 * gd_main_box_generic_get_show_secondary_text:
 * @self:
 *
 * Returns: (transfer none): Whether @self is going to show the
 * secondary-text of each #GdMainBoxItem
 */
gboolean
gd_main_box_generic_get_show_secondary_text (GdMainBoxGeneric *self)
{
  gboolean show_secondary_text;

  g_return_val_if_fail (GD_IS_MAIN_BOX_GENERIC (self), FALSE);

  g_object_get (self, "show-secondary-text", &show_secondary_text, NULL);
  return show_secondary_text;
}

void
gd_main_box_generic_select_all (GdMainBoxGeneric *self)
{
  GdMainBoxGenericInterface *iface;

  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  (* iface->select_all) (self);
}

void
gd_main_box_generic_select_child (GdMainBoxGeneric *self, GdMainBoxChild *child)
{
  GdMainBoxGenericInterface *iface;

  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));
  g_return_if_fail (GD_IS_MAIN_BOX_CHILD (child));

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  (* iface->select_child) (self, child);
}

/**
 * gd_main_box_generic_set_model:
 * @self:
 * @model: (allow-none):
 *
 */
void
gd_main_box_generic_set_model (GdMainBoxGeneric *self, GListModel *model)
{
  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));
  g_return_if_fail (model == NULL || G_IS_LIST_MODEL (model));

  g_object_set (self, "model", model, NULL);
}

/**
 * gd_main_box_generic_set_selection_mode:
 * @self:
 * @selection_mode:
 *
 */
void
gd_main_box_generic_set_selection_mode (GdMainBoxGeneric *self, gboolean selection_mode)
{
  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));
  g_object_set (self, "gd-selection-mode", selection_mode, NULL);
}

/**
 * gd_main_box_generic_set_show_primary_text:
 * @self:
 * @show_primary_text:
 *
 */
void
gd_main_box_generic_set_show_primary_text (GdMainBoxGeneric *self, gboolean show_primary_text)
{
  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));
  g_object_set (self, "show-primary-text", show_primary_text, NULL);
}

/**
 * gd_main_box_generic_set_show_secondary_text:
 * @self:
 * @show_secondary_text:
 *
 */
void
gd_main_box_generic_set_show_secondary_text (GdMainBoxGeneric *self, gboolean show_secondary_text)
{
  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));
  g_object_set (self, "show-secondary-text", show_secondary_text, NULL);
}

void
gd_main_box_generic_unselect_all (GdMainBoxGeneric *self)
{
  GdMainBoxGenericInterface *iface;

  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  (* iface->unselect_all) (self);
}

void
gd_main_box_generic_unselect_child (GdMainBoxGeneric *self, GdMainBoxChild *child)
{
  GdMainBoxGenericInterface *iface;

  g_return_if_fail (GD_IS_MAIN_BOX_GENERIC (self));
  g_return_if_fail (GD_IS_MAIN_BOX_CHILD (child));

  iface = GD_MAIN_BOX_GENERIC_GET_IFACE (self);

  (* iface->unselect_child) (self, child);
}

void
gd_main_box_generic_toggle_selection_for_child (GdMainBoxGeneric *self,
                                                GdMainBoxChild *child,
                                                gboolean select_range)
{
  GListModel *model;

  model = gd_main_box_generic_get_model (self);
  if (model == NULL)
    return;

  if (gd_main_box_child_get_selected (child))
    {
      gd_main_box_generic_unselect_child (self, child);
    }
  else
    {
      if (select_range)
        gd_main_box_generic_select_range (self, child);
      else
        gd_main_box_generic_select_child (self, child);
    }
}
