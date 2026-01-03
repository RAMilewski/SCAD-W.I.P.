from pathlib import Path

ADDON_ROOT = Path(__file__).parent

# Thumb paths
THUMBS_ROOT = ADDON_ROOT / "thumbs"
HEAD_THUMBS = THUMBS_ROOT / "heads"
THREAD_THUMBS = THUMBS_ROOT / "threads"
HOLE_THUMBS = THUMBS_ROOT / "holes"

# Preset resources
PARAMETERS_DIR = Path(__file__).parent / "parameters"
THREAD_PROFILES_CSV = PARAMETERS_DIR / "threads.csv"

# Attribute names
BOLT_ATTR_NAME = "multiboard_bolt_props"
# CACHE_NAME = "multiboard_bolt_preset_cache"

RESOURCES_DIR = ADDON_ROOT / "resources"
MESH_LIBRARY = RESOURCES_DIR / "meshes.blend"

PUSH_FIT_SCALER: float = 0.1
PUSH_FIT_BASE_OFFSET: float = 1.0

DEFAULT_THREAD_RESOLUTION: int = 32

USER_PRESETS = ADDON_ROOT / "user_presets"
PRESETS = ADDON_ROOT / "presets"
PRESET_PROPS = (
    "is_bolt",
    "head_type",
    "thread_type",
    "hole_type",
    "thread_lengh",
    "shank_length",
    "tolerance",
    "thread_resolution",
    "is_tbolt",
    "is_tbol_cap",
    "is_folded",
)

PROP_TYPES = {
    "is_bolt": bool,
    "head_type": str,
    "thread_type": str,
    "hole_type": str,
    "thread_lengh": float,
    "shank_length": float,
    "thread_resolution": int,
    "tolerance": float,
    "is_tbolt": bool,
    "is_tbol_cap": bool,
    "is_folded": bool,
}