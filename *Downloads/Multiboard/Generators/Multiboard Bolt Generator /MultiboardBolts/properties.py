from typing import Iterable
from csv import DictReader
from functools import cache
# import logging
from itertools import chain
from typing import Union
# logger = logging.getLogger(__package__)
# logger.setLevel(logging.DEBUG)

import bpy
from bpy.props import FloatProperty, BoolProperty, EnumProperty, PointerProperty, IntProperty
from bpy.types import PropertyGroup, AddonPreferences, Context
from bpy.utils.previews import ImagePreviewCollection
from .bolt_gen import update_bolt
from . import config


_PLACEHOLDER_ENUM = (("NONE", "None", "None"),)
preview_collections = {}

# NOTE: This is all a big fucking mess
def bpy_enum_from_iterable(iterable: Iterable):
    enum = []
    for i, item in enumerate(iterable):
        enum.append((
            item,
            item.replace("_", " ").title(),
            item.replace("_", " ").title(),
            i,
        ))
    return enum


# BOLT_TYPES = ("regular_bolt", "t_bolt", "folded_bolt")
THREAD_TYPES = (
    "big_thread",
    "mid_thread",
    "small_thread",
)
BOLT_PARAMETERS = (
    "tolerance",
    "thread_length",
    "shank_length",
)
HEAD_TYPES = (
    "standard_head",
    "flat_head",
    "small_head",
    "small_flat_head",
    "small_head_small_thread",
    "small_flat_head_small_thread",
    "standard_head_small_thread",
    "flat_head_small_thread",
    "standard_head_push_fit_big",
    "standard_head_push_fit_mid",
    "flat_head_push_fit_mid",
    "blank",
)
THROUGH_HOLE_TYPES = (
    "none",
    "small_thread_hole",
    "push_fit_hole",
)
# HEAD_HOLE_TYPES = ("none", "plain_head", "small_thread_head", "push_fit_head", "multiboard_head",)

# BOLT_TYPES_ENUM = bpy_enum_from_iterable(BOLT_TYPES)
# THREAD_TYPES_ENUM = bpy_enum_from_iterable(THREAD_TYPES)
# BOLT_PARAMETERS_ENUM = bpy_enum_from_iterable(BOLT_PARAMETERS)
# HEAD_TYPES_ENUM = bpy_enum_from_iterable(HEAD_TYPES)
# HEAD_HOLE_TYPES_ENUM = bpy_enum_from_iterable(HEAD_HOLE_TYPES)
# THROUGH_HOLE_TYPES_ENUM = bpy_enum_from_iterable(THROUGH_HOLE_TYPES)

def _create_types_enum(src_iterable):
    thumb_collection = preview_collections["settings_thumbs"]
    enum =[]
    for i, item in enumerate(src_iterable):
        thumb = preview_collections["settings_thumbs"][item]
        enum.append((item, item, item, thumb.icon_id, i))
    return enum


def _populate_thread_thumbs(self, context):
    return _create_types_enum(THREAD_TYPES)


def _populate_head_thumbs(self, context):
    return _create_types_enum(HEAD_TYPES)


def _populate_hole_thumbs(self, context):
    return _create_types_enum(THROUGH_HOLE_TYPES)

# @cache
# class PresetCache:
#     _CACHE_ATTR_NAME = "multiboard_bolt_preset_cache"

#     @classmethod
#     def get_preset_cache(cls) -> Union[PresetEnum, None] :
#         pass

#     @classmethod
#     def set_preset_cache(cls, enum: PresetEnum):
#         bpy.context.scene[cls._CACHE_ATTR_NAME] = enum

#     @classmethod
#     def clear_preset_cache(cls):
#         bpy.context.scene[cls._CACHE_ATTR_NAME] = None

PresetEnum = tuple[tuple[str, str, str, int]]
preset_cache: Union[None, PresetEnum] = None

def _populate_presets_enum(self, context):
    # print("Loading presets from cache")
    # presets_enum = PresetCache.get_preset_cache()
    global preset_cache
    if preset_cache:
        # print("reading from cache")
        return preset_cache
    # context.scene['fuck'] = "potato"
    # print("Populating presets")
    names = []
    csv_files = chain(config.PRESETS.glob("*.csv"), config.USER_PRESETS.glob("*.csv"))
    for csv in csv_files:
        with open(csv, 'r') as csv_file:
            reader = DictReader(csv_file)
            for line in reader:
                name = line.get("name")
                if name:
                    names.append(name)
    enum = []
    for i, name in enumerate(names):
        enum.append((name, name, name, i))

    preset_cache = enum
    return enum


class MultiboardBoltPreferences(AddonPreferences):
    bl_idname = __package__

    dev_mode: BoolProperty(default=False, options={"SKIP_SAVE"})

    def draw(self, context: Context):
        layout = self.layout
        layout.prop(self, "dev_mode", text="Show Dev Options")


class BoltProperties(PropertyGroup):
    is_bolt: BoolProperty(default=False, update=update_bolt)
    pause_prop_update: BoolProperty(default=False)

    # Ref PrecisionBolts: 
    head_type: EnumProperty(items=_populate_head_thumbs, update=update_bolt)
    thread_type: EnumProperty(items=_populate_thread_thumbs, update=update_bolt)
    hole_type: EnumProperty(items=_populate_hole_thumbs, update=update_bolt)

    # Thread params
    thread_lengh: FloatProperty(default=10, update=update_bolt, min=0.05)
    shank_length: FloatProperty(default=0.0, min=0.0, update=update_bolt)
    tolerance: FloatProperty(default=0.25, update=update_bolt, min=-0.3, max=0.3)
    thread_resolution: IntProperty(default=32, update=update_bolt, min=12, soft_max=128)

    # presets: EnumProperty(items=_PLACEHOLDER_ENUM)
    presets: EnumProperty(items=_populate_presets_enum)

    is_tbolt: BoolProperty(default=False, update=update_bolt)
    is_folded: BoolProperty(default=False, update=update_bolt)
    smooth_shade: BoolProperty(default=False, update=update_bolt)
    is_tbol_cap: BoolProperty(default=False, update=update_bolt)


_to_register = (
    MultiboardBoltPreferences,
    BoltProperties,
)


def register():
    # import bpy
    # import bpy.utils.previews

    # Initialize preview collections
    for cls in _to_register:
        # print(cls)
        # logger.debug(cls)
        bpy.utils.register_class(cls)

    setattr(bpy.types.Object, config.BOLT_ATTR_NAME, PointerProperty(type=BoltProperties))

    # Initialize preview collections
    # heads_pcoll = bpy.utils.previews.new()
    # threads_pcoll = bpy.utils.previews.new()
    # holes_pcol = bpy.utils.previews.new()
    settings_thumbs: ImagePreviewCollection = bpy.utils.previews.new()
    # Load preview thumbs
    for img in config.THUMBS_ROOT.glob("*/*.png"):
        settings_thumbs.load(img.stem, str(img), "IMAGE")

    # Store refs
    preview_collections["settings_thumbs"] = settings_thumbs


    # settings_thumbs.load

    # preview_collections["heads"] = heads_pcoll
    # preview_collections["threads"] = threads_pcoll
    # preview_collections["holes"] = holes_pcol


def unregister():
    delattr(bpy.types.Object, config.BOLT_ATTR_NAME)
    for cls in _to_register:
        bpy.utils.unregister_class(cls)

    for pcoll in preview_collections.values():
        bpy.utils.previews.remove(pcoll)

    preview_collections.clear()
