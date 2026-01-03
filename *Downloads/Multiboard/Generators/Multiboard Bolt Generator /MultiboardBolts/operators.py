from pathlib import Path
from itertools import chain
from typing import Union, Any
from csv import DictReader, DictWriter

import bpy
from bpy.types import Operator, Context, Event, Object
from bpy.props import StringProperty, BoolProperty
from . import config, properties

class OBJECT_OT_create_multiboard_bolt(Operator):
    bl_idname = "object.create_multiboard_bolt"
    bl_label = "Create Multiboard Bolt"
    bl_options = {"UNDO"}

    def execute(self, context: Context):
        bolt_mesh = bpy.data.meshes.new("multiboard_bolt")
        bolt: Object = bpy.data.objects.new("Multiboard Bolt", object_data=bolt_mesh)
        bolt_props = getattr(bolt, config.BOLT_ATTR_NAME)
        context.collection.objects.link(bolt)
        context.view_layer.update()
        context.view_layer.objects.active = bolt
        bolt_props.is_bolt = True

        # Set new bolt location
        bolt.location = context.scene.cursor.location
        return {"FINISHED"}


# def read_preset_names(filepath: Path):
#     names = []
#     with open(filepath, 'r') as preset_file:
#         reader = DictReader(preset_file)
#         for line in reader:
#             names.append(line["name"])
#     return names

class OBJECT_OT_apply_multiboard_bolt_preset(Operator):
    bl_idname = "object.apply_multiboard_bolt_preset"
    bl_label = "Apply Multiboard Bolt Preset"

    preset_name: StringProperty(default="", options={"SKIP_SAVE"})
    target_name: StringProperty(default="", options={"SKIP_SAVE"})

    @staticmethod
    def get_preset_by_name(filepath: Path, name: str) -> Union[dict[str, Any], None]:
        def type_preset(preset_dict):
            typed = dict()
            for key, value in preset_dict.items():
                try:
                    if value.lower() == "false":
                        value = False
                    elif value.lower() == "true":
                        value = True
                    else:
                        value = config.PROP_TYPES[key](value)
                    typed[key] = value
                except KeyError:
                    typed[key] = value
            return typed

        with open(filepath, 'r') as preset_file:
            reader = DictReader(preset_file)
            for line in reader:
                preset_name = line["name"]
                if preset_name == name:
                    return type_preset(line)
        return None

    def execute(self, context: bpy.types.Context):
        if not self.target_name:
            target = context.active_object
        else:
            target = bpy.data.objects.get(self.target)
        bolt_props = getattr(target, config.BOLT_ATTR_NAME)
        if not self.preset_name:
            self.preset_name = bolt_props.presets

        user_preset_files = config.USER_PRESETS.glob("*.csv")
        preset_files = config.PRESETS.glob("*.csv")
        for preset_file in chain(user_preset_files, preset_files):
            preset = self.get_preset_by_name(preset_file, self.preset_name)
            if preset:
                break
        else:
            self.report({"ERROR"}, f"Cannot find preset, {self.preset_name}")
            return {"CANCELLED"}

        bolt_props.pause_prop_update = True
        for key, value in preset.items():
            try:
                setattr(bolt_props, key, value)
            except:
                continue

        bolt_props.pause_prop_update = False
        bolt_props.head_type = bolt_props.head_type
        return {"FINISHED"}


class OBJECT_OT_save_multiboard_bolt_preset(Operator):
    bl_idname = "object.save_multiboard_bolt_preset"
    bl_label = "Apply Multiboard Bolt Preset"

    preset_name: StringProperty(default="", name="Preset Name")
    is_user_preset: BoolProperty(default=True, options={"HIDDEN"})

    def invoke(self, context: Context, event: Event):
        return context.window_manager.invoke_props_dialog(self)

    def execute(self, context: bpy.types.Context):
        bolt = context.active_object
        bolt_props: properties.BoltProperties = getattr(bolt, config.BOLT_ATTR_NAME)
        if not bolt_props.is_bolt:
            self.report({"ERROR"}, f"Cannot save preset, {bolt} not bolt")
            return {"CANCELLED"}

        output_dir = config.USER_PRESETS if self.is_user_preset else config.PRESETS
        output_name = f"{self.preset_name}.csv"
        print(f"Saving preset: {self.preset_name} to {output_dir / output_name}")
        with open(output_dir / output_name, 'w') as preset_file:
            fieldnames = ["name",] + list(config.PRESET_PROPS)
            writer = DictWriter(preset_file, fieldnames=fieldnames)
            writer.writeheader()
            preset = dict()
            preset["name"] = self.preset_name
            for prop in config.PRESET_PROPS:
                preset[prop] = getattr(bolt_props, prop)
            writer.writerow(preset)
        
        # properties.PresetCache.clear_preset_cache()
        properties.preset_cache = None
        return {"FINISHED"}


classes = (
    OBJECT_OT_save_multiboard_bolt_preset,
    OBJECT_OT_create_multiboard_bolt,
    OBJECT_OT_apply_multiboard_bolt_preset,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)


def unregister():
    for cls in classes:
        bpy.utils.unregister_class(cls)