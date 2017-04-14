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

#include "gd-main-box.h"
#include "gd-main-box-child.h"
#include "gd-main-box-generic.h"
#include "gd-main-icon-box.h"

#define MAIN_BOX_TYPE_INITIAL -1

typedef struct _GdMainBoxPrivate GdMainBoxPrivate;

struct _GdMainBoxPrivate
{
  GListModel *model;
  GdMainBoxType current_type;
  GtkWidget *current_box;
  GtkWidget *frame;
  gboolean selection_mode;
  gboolean show_primary_text;
  gboolean show_secondary_text;
};

enum
{
  PROP_BOX_TYPE = 1,
  PROP_SELECTION_MODE,
  PROP_SHOW_PRIMARY_TEXT,
  PROP_SHOW_SECONDARY_TEXT,
  PROP_MODEL,
  NUM_PROPERTIES
};

enum
{
  ITEM_ACTIVATED,
  SELECTION_CHANGED,
  SELECTION_MODE_REQUEST,
  NUM_SIGNALS
};

static GParamSpec *properties[NUM_PROPERTIES] = { NULL, };
static guint signals[NUM_SIGNALS] = { 0, };

G_DEFINE_TYPE_WITH_PRIVATE (GdMainBox, gd_main_box, GTK_TYPE_BIN)

static void
gd_main_box_activate_item_for_child (GdMainBox *self, GdMainBoxChild *child)
{
  GdMainBoxPrivate *priv;
  GdMainBoxItem *item;

  priv = gd_main_box_get_instance_private (self);

  if (priv->model == NULL)
    return;

  item = gd_main_box_child_get_item (child);
  if (item == NULL)
    return;

  g_signal_emit (self, signals[ITEM_ACTIVATED], 0, item);
}

static void
gd_main_box_apply_selection_mode (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  gd_main_box_generic_set_selection_mode (GD_MAIN_BOX_GENERIC (priv->current_box), priv->selection_mode);

  if (!priv->selection_mode)
    {
      if (priv->model != NULL)
        gd_main_box_unselect_all (self);
    }
}

static void
gd_main_box_item_activated_cb (GdMainBox *self, GdMainBoxChild *child)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (!priv->selection_mode)
    gd_main_box_activate_item_for_child (self, child);
}

static void
gd_main_box_selection_changed_cb (GdMainBox *self)
{
  g_signal_emit (self, signals[SELECTION_CHANGED], 0);
}

static void
gd_main_box_selection_mode_request_cb (GdMainBox *self)
{
  g_signal_emit (self, signals[SELECTION_MODE_REQUEST], 0);
}

static void
gd_main_box_rebuild (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (priv->current_box != NULL)
    gtk_widget_destroy (priv->current_box);

  switch (priv->current_type)
    {
    case GD_MAIN_BOX_ICON:
      priv->current_box = gd_main_icon_box_new ();
      break;

    case GD_MAIN_BOX_LIST:
    default:
      g_assert_not_reached ();
      break;
    }

  gtk_widget_set_hexpand (priv->current_box, TRUE);
  gtk_widget_set_valign (priv->current_box, GTK_ALIGN_START);
  g_object_bind_property (self, "show-primary-text",
                          priv->current_box, "show-primary-text",
                          G_BINDING_SYNC_CREATE);
  g_object_bind_property (self, "show-secondary-text",
                          priv->current_box, "show-secondary-text",
                          G_BINDING_SYNC_CREATE);
  gtk_container_add (GTK_CONTAINER (priv->frame), priv->current_box);

  g_signal_connect_swapped (priv->current_box,
                            "item-activated",
                            G_CALLBACK (gd_main_box_item_activated_cb),
                            self);
  g_signal_connect_swapped (priv->current_box,
                            "selection-changed",
                            G_CALLBACK (gd_main_box_selection_changed_cb),
                            self);
  g_signal_connect_swapped (priv->current_box,
                            "selection-mode-request",
                            G_CALLBACK (gd_main_box_selection_mode_request_cb),
                            self);

  gd_main_box_generic_set_model (GD_MAIN_BOX_GENERIC (priv->current_box), priv->model);
  gd_main_box_apply_selection_mode (self);

  gtk_widget_show_all (GTK_WIDGET (self));
}

static void
gd_main_box_dispose (GObject *obj)
{
  GdMainBox *self = GD_MAIN_BOX (obj);
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  g_clear_object (&priv->model);

  G_OBJECT_CLASS (gd_main_box_parent_class)->dispose (obj);
}

static void
gd_main_box_init (GdMainBox *self)
{
  GdMainBoxPrivate *priv;
  GtkStyleContext *context;

  priv = gd_main_box_get_instance_private (self);

  priv->frame = gtk_frame_new (NULL);
  context = gtk_widget_get_style_context (priv->frame);
  gtk_style_context_add_class (context, "content-view");
  gtk_container_add (GTK_CONTAINER (self), priv->frame);

  /* so that we get constructed with the right view even at startup */
  priv->current_type = MAIN_BOX_TYPE_INITIAL;
}

static void
gd_main_box_get_property (GObject *object, guint property_id, GValue *value, GParamSpec *pspec)
{
  GdMainBox *self = GD_MAIN_BOX (object);

  switch (property_id)
    {
    case PROP_BOX_TYPE:
      g_value_set_int (value, gd_main_box_get_box_type (self));
      break;
    case PROP_SELECTION_MODE:
      g_value_set_boolean (value, gd_main_box_get_selection_mode (self));
      break;
    case PROP_SHOW_PRIMARY_TEXT:
      g_value_set_boolean (value, gd_main_box_get_show_primary_text (self));
      break;
    case PROP_SHOW_SECONDARY_TEXT:
      g_value_set_boolean (value, gd_main_box_get_show_secondary_text (self));
      break;
    case PROP_MODEL:
      g_value_set_object (value, gd_main_box_get_model (self));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_box_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec)
{
  GdMainBox *self = GD_MAIN_BOX (object);

  switch (property_id)
    {
    case PROP_BOX_TYPE:
      gd_main_box_set_box_type (self, g_value_get_int (value));
      break;
    case PROP_SELECTION_MODE:
      gd_main_box_set_selection_mode (self, g_value_get_boolean (value));
      break;
    case PROP_SHOW_PRIMARY_TEXT:
      gd_main_box_set_show_primary_text (self, g_value_get_boolean (value));
      break;
    case PROP_SHOW_SECONDARY_TEXT:
      gd_main_box_set_show_secondary_text (self, g_value_get_boolean (value));
      break;
    case PROP_MODEL:
      gd_main_box_set_model (self, g_value_get_object (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
      break;
    }
}

static void
gd_main_box_class_init (GdMainBoxClass *klass)
{
  GObjectClass *oclass = G_OBJECT_CLASS (klass);
  GtkWidgetClass *wclass = GTK_WIDGET_CLASS (klass);

  oclass->get_property = gd_main_box_get_property;
  oclass->set_property = gd_main_box_set_property;
  oclass->dispose = gd_main_box_dispose;

  properties[PROP_BOX_TYPE] = g_param_spec_int ("box-type",
                                                "Box type",
                                                "Box type",
                                                GD_MAIN_BOX_ICON,
                                                GD_MAIN_BOX_LIST,
                                                GD_MAIN_BOX_ICON,
                                                G_PARAM_EXPLICIT_NOTIFY |
                                                G_PARAM_READWRITE |
                                                G_PARAM_CONSTRUCT |
                                                G_PARAM_STATIC_STRINGS);

  properties[PROP_MODEL] = g_param_spec_object ("model",
                                                "Model",
                                                "The GListModel",
                                                G_TYPE_LIST_MODEL,
                                                G_PARAM_EXPLICIT_NOTIFY |
                                                G_PARAM_READWRITE |
                                                G_PARAM_CONSTRUCT |
                                                G_PARAM_STATIC_STRINGS);

  properties[PROP_SELECTION_MODE] = g_param_spec_boolean ("selection-mode",
                                                          "Selection mode",
                                                          "Whether the view is in selection mode",
                                                          FALSE,
                                                          G_PARAM_EXPLICIT_NOTIFY |
                                                          G_PARAM_READWRITE |
                                                          G_PARAM_CONSTRUCT |
                                                          G_PARAM_STATIC_STRINGS);

  properties[PROP_SHOW_PRIMARY_TEXT] = g_param_spec_boolean ("show-primary-text",
                                                             "Show primary text",
                                                             "Whether each GdMainBoxItem's primary-text is going "
                                                             "to be shown",
                                                             FALSE,
                                                             G_PARAM_EXPLICIT_NOTIFY |
                                                             G_PARAM_READWRITE |
                                                             G_PARAM_CONSTRUCT |
                                                             G_PARAM_STATIC_STRINGS);

  properties[PROP_SHOW_SECONDARY_TEXT] = g_param_spec_boolean ("show-secondary-text",
                                                               "Show secondary text",
                                                               "Whether each GdMainBoxItem's secondary-text is "
                                                               "going to be shown",
                                                               FALSE,
                                                               G_PARAM_EXPLICIT_NOTIFY |
                                                               G_PARAM_READWRITE |
                                                               G_PARAM_CONSTRUCT |
                                                               G_PARAM_STATIC_STRINGS);

  signals[ITEM_ACTIVATED] = g_signal_new ("item-activated",
                                          GD_TYPE_MAIN_BOX,
                                          G_SIGNAL_RUN_LAST,
                                          0,
                                          NULL,
                                          NULL,
                                          g_cclosure_marshal_VOID__OBJECT,
                                          G_TYPE_NONE,
                                          1,
                                          GD_TYPE_MAIN_BOX_ITEM);

  signals[SELECTION_CHANGED] = g_signal_new ("selection-changed",
                                             GD_TYPE_MAIN_BOX,
                                             G_SIGNAL_RUN_LAST,
                                             0,
                                             NULL,
                                             NULL,
                                             g_cclosure_marshal_VOID__VOID,
                                             G_TYPE_NONE,
                                             0);

  signals[SELECTION_MODE_REQUEST] = g_signal_new ("selection-mode-request",
                                                  GD_TYPE_MAIN_BOX,
                                                  G_SIGNAL_RUN_LAST,
                                                  0,
                                                  NULL,
                                                  NULL,
                                                  g_cclosure_marshal_VOID__VOID,
                                                  G_TYPE_NONE,
                                                  0);

  g_object_class_install_properties (oclass, NUM_PROPERTIES, properties);
}

GtkWidget *
gd_main_box_new (GdMainBoxType type)
{
  return g_object_new (GD_TYPE_MAIN_BOX, "box-type", type, NULL);
}

GdMainBoxType
gd_main_box_get_box_type (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  return priv->current_type;
}

void
gd_main_box_set_box_type (GdMainBox *self, GdMainBoxType type)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (type == priv->current_type)
    return;

  priv->current_type = type;
  gd_main_box_rebuild (self);
  g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_BOX_TYPE]);
}

gboolean
gd_main_box_get_selection_mode (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  return priv->selection_mode;
}

gboolean
gd_main_box_get_show_primary_text (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  return priv->show_primary_text;
}

gboolean
gd_main_box_get_show_secondary_text (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  return priv->show_secondary_text;
}

void
gd_main_box_set_selection_mode (GdMainBox *self, gboolean selection_mode)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (selection_mode == priv->selection_mode)
    return;

  priv->selection_mode = selection_mode;
  gd_main_box_apply_selection_mode (self);
  g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_SELECTION_MODE]);
}

void
gd_main_box_set_show_primary_text (GdMainBox *self, gboolean show_primary_text)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (show_primary_text == priv->show_primary_text)
    return;

  priv->show_primary_text = show_primary_text;
  g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_SHOW_PRIMARY_TEXT]);
}

void
gd_main_box_set_show_secondary_text (GdMainBox *self, gboolean show_secondary_text)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (show_secondary_text == priv->show_secondary_text)
    return;

  priv->show_secondary_text = show_secondary_text;
  g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_SHOW_SECONDARY_TEXT]);
}

/**
 * gd_main_box_get_model:
 * @self:
 *
 * Returns: (transfer none):
 */
GListModel *
gd_main_box_get_model (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  return priv->model;
}

/**
 * gd_main_box_set_model:
 * @self:
 * @model: (allow-none):
 *
 */
void
gd_main_box_set_model (GdMainBox *self, GListModel *model)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);

  if (!g_set_object (&priv->model, model))
    return;

  gd_main_box_generic_set_model (GD_MAIN_BOX_GENERIC (priv->current_box), priv->model);
  g_object_notify_by_pspec (G_OBJECT (self), properties[PROP_MODEL]);
}

/**
 * gd_main_box_get_generic_box:
 * @self:
 *
 * Returns: (transfer none):
 */
GtkWidget *
gd_main_box_get_generic_box (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  return priv->current_box;
}

/**
 * gd_main_box_get_selection:
 * @self:
 *
 * Returns: (element-type GdMainBoxItem) (transfer full):
 */
GList *
gd_main_box_get_selection (GdMainBox *self)
{
  GdMainBoxPrivate *priv;
  GList *l;
  GList *selected_children;
  GList *selection = NULL;

  priv = gd_main_box_get_instance_private (self);

  selected_children = gd_main_box_generic_get_selected_children (GD_MAIN_BOX_GENERIC (priv->current_box));
  for (l = selected_children; l != NULL; l = l->next)
    {
      GdMainBoxChild *child = GD_MAIN_BOX_CHILD (l->data);
      GdMainBoxItem *item;

      item = gd_main_box_child_get_item (child);
      selection = g_list_prepend (selection, g_object_ref (item));
    }

  selection = g_list_reverse (selection);
  g_list_free (selected_children);
  return selection;
}

void
gd_main_box_select_all (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  gd_main_box_generic_select_all (GD_MAIN_BOX_GENERIC (priv->current_box));
}

void
gd_main_box_unselect_all (GdMainBox *self)
{
  GdMainBoxPrivate *priv;

  priv = gd_main_box_get_instance_private (self);
  gd_main_box_generic_unselect_all (GD_MAIN_BOX_GENERIC (priv->current_box));
}
