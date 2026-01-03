from __future__ import annotations
from typing import TYPE_CHECKING

import bpy
from bpy.types import Context, UILayout, Panel, Operator
from bpy.props import StringProperty, BoolProperty

from . import config
from . import bolt_gen
from . import operators

if TYPE_CHECKING:
    from .properties import BoltProperties

def set_precision_modeling():
    bpy.context.scene.unit_settings.scale_length = 0.001
    bpy.context.scene.unit_settings.system = 'METRIC'
    bpy.context.scene.unit_settings.length_unit = 'MILLIMETERS'
    for area in bpy.context.screen.areas:
        if area.type == 'VIEW_3D':
            for space in area.spaces:
                if space.type == 'VIEW_3D':
                    space.overlay.grid_scale = 0.001
                    space.clip_start = 0.1
                    space.clip_end = 1000000

class OBJECT_OT_set_precision_modeling(Operator):
    bl_idname = "object.set_precision_modeling"
    bl_label = "Set Precision Modeling"
    bl_description = "Set scene units to millimeters and adjust view settings for precision modeling"

    def execute(self, context: Context):
        set_precision_modeling()
        self.report({'INFO'}, "Precision modeling settings applied")
        return {'FINISHED'}

class VIEW3D_PT_multiboard_bolts(Panel):
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "Multiboard"
    bl_idname = "VIEW3D_PT_multiboard_bolts_edit"
    bl_label = "Multiboard Bolts"

    def _draw_dev_options(self, context: Context):
        if not context.preferences.addons[__package__].preferences.dev_mode:
            return None
        box: UILayout = self.layout.box()
        box.label(text="Dev mode options")
        save_user_preset = box.operator(operators.OBJECT_OT_save_multiboard_bolt_preset.bl_idname, text="Save Addon Preset")
        save_user_preset.is_user_preset = False

    def _active_is_bolt(self, context: Context) -> bool:
        def _conditions():
            yield context.active_object is not None
            bolt_props = getattr(context.active_object, config.BOLT_ATTR_NAME)
            yield bolt_props.is_bolt
        return all(_conditions())

    def draw(self, context: Context):
        layout = self.layout
        col: UILayout = layout.column()

        if abs(bpy.context.scene.unit_settings.scale_length - 0.001) > 1e-6:
            col.operator("object.set_precision_modeling", text="Set Precision Modeling", icon='SETTINGS')

        col.operator(operators.OBJECT_OT_create_multiboard_bolt.bl_idname, text="New Bolt")
        if self._active_is_bolt(context):
            props: BoltProperties = getattr(context.active_object, config.BOLT_ATTR_NAME)
            if not props.is_bolt:
                col.operator(operators.OBJECT_OT_create_multiboard_bolt.bl_idname, text="New Bolt")
            else:
                col.label(text="Head")
                col.template_icon_view(props, "head_type", show_labels=False, scale=7)

                col.label(text="Thread")
                col.template_icon_view(props, "thread_type", show_labels=False, scale=7)
                sub_col = col.column(align=True)
                sub_col.prop(props,"thread_lengh", text="Length")
                sub_col.prop(props,"shank_length", text="Shank Length")
                sub_col.prop(props,"tolerance", text="Tolerance")
                sub_col.prop(props,"thread_resolution", text="Resolution")

                col.label(text="Through Hole")
                col.template_icon_view(props, "hole_type", show_labels=False, scale=7)

                row = col.row()
                row.prop(props, "is_tbolt", text="T-Bolt")
                row.prop(props, "is_folded", text="Folded")

                col.prop(props, "smooth_shade", text="Smooth Shade")
                col.prop(props, "presets", text="Presets")
                col.operator(operators.OBJECT_OT_apply_multiboard_bolt_preset.bl_idname, text="Apply Preset")
                save_user_preset = col.operator(operators.OBJECT_OT_save_multiboard_bolt_preset.bl_idname, text="Save Preset")
                save_user_preset.is_user_preset = True

            self._draw_dev_options(context)

classes = (
    OBJECT_OT_set_precision_modeling,
    VIEW3D_PT_multiboard_bolts,
)

def register():
    for cls in classes:
        bpy.utils.register_class(cls)

def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
