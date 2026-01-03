bl_info = {
    "name": "Multiboard Bolts",
    "description": "multiboard.io",
    "author": "Missing Field <themissingfield.com>",
    "version": (0, 1, 2),
    "blender": (4, 00, 0),
    "location": "View3D",
    "category": "Object",
}

from . import ui
from . import properties
from . import operators

registration_queue = (
    # bolt_gen,
    operators,
    properties,
    ui,
)

def register():
    for item in registration_queue:
        item.register()


def unregister():
    for item in registration_queue:
        item.unregister()

