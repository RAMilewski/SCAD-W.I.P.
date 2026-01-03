"""
Fastener definitions and mesh generation functions


IN PROGRESS:
    Rewriting all components to be output individually as mesh datablocks

    merge datablocks by calliing bm.from_mesh multiple times
"""

from __future__ import annotations, division
from pathlib import Path
from collections import deque
from dataclasses import dataclass, field
from functools import cached_property
from math import pi, radians, tan, sqrt
from typing import TYPE_CHECKING, List, Literal, Union, Iterable, Dict, Optional, Tuple
from itertools import chain
from concurrent.futures import ProcessPoolExecutor

import bpy
from bpy.types import Mesh
import bmesh
from bmesh.types import BMesh, BMVert, BMEdge, BMFace
from mathutils import Vector, Matrix, Euler
import numpy as np

from . import bm_help



# /nuts.blend
MESH_DATA_DIR = Path(__file__).parent / "meshdata"

if not MESH_DATA_DIR.exists():
    MESH_DATA_DIR = Path("/home/field/active_projects/blender-addons/MakerTales/PrecisionBolts/mesh_fasteners/meshdata")

if not MESH_DATA_DIR.exists():
    raise ValueError(f"Could not find {MESH_DATA_DIR}")


DRIVERS_BLEND_FILE = MESH_DATA_DIR / "drivers.blend"
HEADS_BLEND_FILE = MESH_DATA_DIR / "/heads.blend"
NUTS_BLEND_FILE = MESH_DATA_DIR / "nuts.blend"


def map_range(value: float, range_a: Tuple[float, float], range_b: Tuple[float, float]):
    try:
        (a1, a2), (b1, b2) = range_a, range_b
        remapped = b1 + ((value - a1) * (b2 - b1) / (a2 - a1))
        return remapped
    except ZeroDivisionError:
        return 0 


@dataclass
class ThreadProfile:
    """
    TODO: Per profile required inputs should be documented
    """
    pitch: float = 1.25
    length: float = 10.0
    starts: int = 1
    height: float = field(init=False)  # Height of triangle
    depth: float = field(init=False)  # Thread depth
    thread_angle: float = field(init=False)
    # helix_angle: float = field(init=False)
    major_diameter: float = 10
    minor_diameter: float = 1.2
    major_radius: float = field(init=False)
    minor_radius: float = field(init=False)
    # pitch_diameter: float = field(init=False)
    root_width: float = 1.0  # Root length
    crest_width: float = 1.0  # Crest length
    crest_truncation: float = field(init=False)  # Distance between triangle crest and crest, for bevel
    root_truncation: float = field(init=False)  # Distance between triangle root and root, for bevel
    sharp_crest: bool = False
    profile_type: Literal["ISO_68_1", "CUSTOM"] = "ISO_68_1"
    # major_radius: float = field(init=False)
    # minor_radius: float = field(init=False)

    # tolerance: float = 0.0
    def __post_init__(self):
        # scaler = (self.root_width + self.crest_width) / self.pitch

        if self.profile_type == "CUSTOM":
            """
            Required inputs:
                - Major Diameter
                - Minor Diameter
                - Pitch
              mesh_gen.py  - Crest Percentage
                - Root Percentage
            """
            self.root_width *= self.pitch
            self.crest_width *= self.pitch
            self.height = sqrt(3) / 2 * self.pitch
            self.depth = self.major_diameter - self.minor_diameter
            self.root_truncation = self.height / 4
            self.crest_truncation = self.height - self.root_truncation - self.depth
        elif self.profile_type == "ISO_68_1":
            """
            ISO 68-1 Metric Screw Threads
            height = sqrt(3) / 2 * pitch
            thread_angle = 60 degrees
            Required inputs: ???
                - Major Diameter
                - Pitch
            """
            self.thread_angle = radians(60)
            self.height = sqrt(3) / 2 * self.pitch
            self.minor_diameter = self.major_diameter - (2 * (5 / 8 * self.height))
            self.depth = 3 / 8 * self.height
            self.root_width = self.pitch / 4
            self.crest_width = self.pitch / 8
            self.root_truncation = self.height / 4
            self.crest_truncation = self.height - self.root_truncation - self.depth
        else:
            raise ValueError(f"Unrecognized profile type {self.profile_type}")

        self.major_radius = self.major_diameter * 0.5
        self.minor_radius = self.minor_diameter * 0.5

    @property
    def flank_width(self):
        return (self.pitch - self.root_width - self.crest_width) / 2

    def feature_by_index(self, index) -> str:
        """Return feature name of a point by it's index"""
        index = index % 4
        if index < 2:
            return "root"
        return "crest"

    @property
    def section(self):
        """
        left to right, root to crest
        x_axis == screw_axis
        """
        a = np.array([0, (self.minor_diameter / 2)])
        b = a + (self.root_width, 0)
        c = np.array([self.flank_width + self.root_width, self.major_diameter / 2])
        d = c + (self.crest_width, 0)
        if self.sharp_crest:
            c += (self.crest_width / 2, 0)
            d = np.copy(c)
        return np.vstack((a, b, c, d))

    @cached_property
    def points(self) -> list[Vector]:
        # TODO: n_sections is incorrect, the scaling by 2  + 4is a hacky fix
        n_sections = int(self.length / self.pitch * self.starts) * 2 + 4
        full_profile = np.copy(self.section)
        for index in range(1, n_sections):
            offset_section = np.copy(self.section) + (self.pitch * index, 0)
            full_profile = np.vstack((full_profile, offset_section))
        return [Vector((coord[1], 0, coord[0])) for coord in full_profile]


def _np2d_to_v3d(coord: np.ndarray) -> Vector:
    """[a,b] np to [b, 0, a] vector"""
    return Vector((coord[1], 0, coord[0]))


# def _get_unique_vert_edges(verts: Iterable[BMVert]) -> list[BMEdge]:
#     return list(set(chain.from_iterable(v.link_edges for v in verts)))


def create_washer(
    tolerance: float = 0.0,
    thickness: float = 1.0,
    minor_diameter: float = 1.0,
    major_diameter: float = 2.0,
    spin_resolution: int = 32,
    name: str = "washer",
) -> bpy.types.Mesh:
    # TODO: expand functionality
    #   - square outer perimiter toggle
    #   - bending
    #   - grid mesh

    # Create Profile
    bm = bmesh.new()

    profile_verts = bmesh.ops.create_circle(bm, segments=4, radius=1)["verts"]
    bm.verts.ensure_lookup_table()
    profile_verts[0].co = Vector((minor_diameter * 0.5 - tolerance, 0, thickness * 0.5))
    profile_verts[1].co = Vector((major_diameter * 0.5, 0, thickness * 0.5))
    profile_verts[2].co = Vector((major_diameter * 0.5, 0, -(thickness * 0.5)))
    profile_verts[3].co = Vector((minor_diameter * 0.5 - tolerance, 0, -(thickness * 0.5)))
    profile_edges = list(set(chain.from_iterable(v.link_edges for v in bm.verts)))

    # Sweep Profile
    bm.edges.ensure_lookup_table()
    bmesh.ops.spin(
        bm,
        geom=profile_edges,
        axis=Vector((0, 0, 1)),
        angle=2 * pi,
        steps=spin_resolution,
        use_merge=True,
    )
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    return mesh

def create_thread(
    mesh: Union[BMesh, Mesh],
    thread_profile: ThreadProfile = ThreadProfile(),
    divisions: int = 32,
    reverse_thread: bool = False,
    internal: bool = False,
    cap_top: bool = False,
    cap_bottom: bool = False,
    terminate_outward: bool = True,
    smooth_top_termination: bool = True,
    smooth_bottom_termination: bool = True,
) -> bpy.types.Mesh:
    """
    Create thread mesh as new mesh object
    Created thread has no caps, but returns seperate int attributes for those boundaries

    Output mesh attributes
        int: vert["thread_crest"]
        int: vert["thread_root"]

        int: edge["top_edges"]
        int: edge["bottom_edges"]

        int: face["top_face"]
        int: face["bottom_face"]
    """
    input_is_bmesh = isinstance(mesh, BMesh)
    if not input_is_bmesh:
        bm = bmesh.new()
        bm.from_mesh(mesh)
    else:
        bm = mesh

    # Declare descriptor attribs
    # TODO: Should use existing if present in bm
    crest_attrib = bm.verts.layers.int.new("thread_crest")
    root_attrib = bm.verts.layers.int.new("thread_root")
    thread_top_attrib = bm.edges.layers.int.new("top_edges")
    thread_bottom_attrib = bm.edges.layers.int.new("bottom_edges")
    top_face_attrib = bm.faces.layers.int.new("top_face")
    bottom_face_attrib = bm.faces.layers.int.new("bottom_face")

    # Create profile verts and assign their descriptor attribs
    profile_verts = []
    for index, p in enumerate(thread_profile.points):
        vert = bm.verts.new(p)
        profile_verts.append(vert)

        if thread_profile.feature_by_index(index) == "crest":
            vert[crest_attrib] = 1
        else:
            vert[root_attrib] = 1

    # Create profile edges
    profile_edges = []
    for v1, v2 in zip(profile_verts, profile_verts[1:]):
        profile_edges.append(bm.edges.new((v1, v2)))

    # Spin/Revolve profile
    step_z = thread_profile.pitch * thread_profile.starts / divisions
    axis = Vector((0, 0, 1))
    dvec = Vector((0, 0, step_z))

    if reverse_thread:
        angle = -radians(360)
        flip_normal = False
    else:
        angle = radians(360)
        flip_normal = True

    if internal:
        flip_normal = not flip_normal

    spun = bmesh.ops.spin(
        bm,
        geom=profile_edges,
        angle=angle,
        steps=divisions,
        dvec=dvec,
        axis=axis,
        use_normal_flip=flip_normal
    )
    end_verts = [item for item in spun["geom_last"] if isinstance(item, BMVert)]

    merge_dist = 0.0001
    # boundary_verts = [vert for vert in chain(profile_verts, end_verts) if vert.is_boundary]  # NOTE: Not sure why I was previously ensuring boundary points
    boundary_verts = profile_verts + end_verts
    bmesh.ops.remove_doubles(bm, verts=boundary_verts, dist=merge_dist)

    # Clip top and bottom
    z_offset = -(thread_profile.starts * thread_profile.pitch)
    xform = Vector((0, 0, z_offset))
    bmesh.ops.translate(bm, vec=xform, verts=bm.verts)
    geom = bm.verts[:] + bm.edges[:] + bm.faces[:]
    bmesh.ops.bisect_plane(bm, geom=geom, dist=0.0, plane_co=(0, 0, 0), plane_no=(0, 0, -1), clear_outer=True, use_snap_center=True)
    geom = bm.verts[:] + bm.edges[:] + bm.faces[:]
    bmesh.ops.bisect_plane(bm, geom=geom, dist=0.0, plane_co=(0, 0, thread_profile.length), plane_no=(0, 0, 1), clear_outer=True, use_snap_center=False)

    # Cleanup trimmed boundaries by merging remove doubles bounds and bounds neighbors
    geom = set()
    for vert in bm.verts:
        if not vert.is_boundary:
            continue
        geom.add(vert)
        for edge in vert.link_edges:
            geom.add(edge.other_vert(vert))

    merge_dist = 0.0001
    bmesh.ops.remove_doubles(bm, verts=list(geom), dist=merge_dist)

    top_edges = []
    bottom_edges = []
    for edge in bm.edges:
        if not edge.is_boundary:
            continue

        # If is top vert
        if edge.verts[0].co.z > (thread_profile.length * 0.5):
            top_edges.append(edge)
            if not cap_top:
                edge[thread_top_attrib] = 1
        else:
            bottom_edges.append(edge)
            if not cap_bottom:
                edge[thread_bottom_attrib] = 1

    if cap_top:
        new_faces = bmesh.ops.holes_fill(bm, edges=top_edges)["faces"]
        for face in new_faces:
            face[top_face_attrib] = 1
    if cap_bottom:
        new_faces = bmesh.ops.holes_fill(bm, edges=bottom_edges)["faces"]
        for face in new_faces:
            face[bottom_face_attrib] = 1

    # Smooth termination
    if terminate_outward:
        target_radius = thread_profile.major_diameter * 0.55
    else:
        target_radius = thread_profile.major_diameter * 0.45
    # affected_distance = thread_profile.length * 0.1
    affected_distance = thread_profile.pitch * 0.5
    
    # From no effect to full (target_radius)
    top_range = (thread_profile.length - affected_distance, thread_profile.length)
    bottom_range = (affected_distance, 0)

    for vert in bm.verts:
        xy, z = vert.co.xy, vert.co.z
        if z <= bottom_range[0] and smooth_bottom_termination:
            effect_range = bottom_range
        elif z >= top_range[0] and smooth_top_termination:
            effect_range = top_range
        else:
            continue
        init_mag = xy.length
        z += 0.000001
        target_mag = map_range(z, effect_range, (init_mag, target_radius))
        vert.co.xy = xy.normalized() * target_mag

    if not input_is_bmesh:
        bm.to_mesh(mesh)
        bm.free


def apply_shape_keys(
    bm: BMesh,
    shape_params: Optional[Dict[str, float]] = None
) -> None:
    """
    Apply shape keys by fac on bmesh object
    shape_param: Dict of {shape_key layer name: layer fac} to apply nut source meshes keys
                 Default vert locs are used as rest position
    """
    if shape_params:
        layer_weights = dict()
        for layer_name, fac in shape_params.items():
            layer_weights[bm.verts.layers.shape[layer_name]] = fac

        for vert in bm.verts:
            offset = Vector((0, 0, 0))
            for shape_layer, fac in layer_weights.items():
                offset += ((vert[shape_layer] - vert.co) * fac)
            vert.co += offset

def create_polygonal_nut(
    mesh: Union[BMesh, Mesh],
    nut_length: float = 1,
    nut_diameter: float = 4,
    sides: int = 6,
    crown_chamfer: float = 0.0,
    root_chamfer: float = 0.0,
    chamfer_subdiv: int = 1,
) -> BMesh:
    input_is_bm = isinstance(mesh, BMesh)
    if not input_is_bm:
        nut_bm = bmesh.new()
        nut_bm.from_mesh(mesh)
    else:
        nut_bm = mesh

    radius = nut_diameter * 0.5
    offset = Matrix.Translation(Vector((0, 0, nut_length * 0.5)))
    bmesh.ops.create_cone(
        nut_bm, cap_ends=True, radius1=radius, radius2=radius,
        depth=nut_length, segments=sides, matrix=offset
    )
    top_verts = []
    bottom_verts = []
    half_height = nut_length * 0.5
    for v in nut_bm.verts:
        if v.co.z > half_height:
            top_verts.append(v)
        else:
            bottom_verts.append(v)
    
    bottom_edges = bm_help.shared_edges(bottom_verts)
    top_edges = bm_help.shared_edges(top_verts)

    if crown_chamfer != 0.0:
        bmesh.ops.bevel(
            nut_bm, geom=top_edges, offset=crown_chamfer, affect="VERTICES",
            segments=chamfer_subdiv, profile=0.5
        )
    if root_chamfer != 0.0:
        bmesh.ops.bevel(
            nut_bm, geom=bottom_edges, offset=root_chamfer, affect="VERTICES",
            segments=chamfer_subdiv, profile=0.5)

    top_attrib = nut_bm.edges.layers.int.new("top_edges")
    bottom_attrib = nut_bm.edges.layers.int.new("bottom_edges")
    to_delete = []
    for face in nut_bm.faces:
        dot = face.normal.dot(Vector((0, 0, 1)))
        is_top_face = dot > 0.99
        is_bottom_face = dot < -0.99

        if is_top_face:
            bm_help.set_attib_values(face.edges, top_attrib, 1)
            to_delete.append(face)
        elif is_bottom_face:
            bm_help.set_attib_values(face.edges, bottom_attrib, 1)
            to_delete.append(face)

    bmesh.ops.delete(nut_bm, geom=to_delete, context="FACES")

    if not input_is_bm:
        nut_bm.to_mesh(mesh)
        nut_bm.free()

    return mesh


def create_nut_body(
    mesh: Union[BMesh, Mesh],
    body_type: Literal["HEX", "SQUARE", "DOME", "FLANGE"] = "HEX",
    # name: str = "nut",
    shape_params: Optional[Dict[str, float]] = None,
    diameter: float = 1.0,
    length: float = 1.0,
) -> bpy.types.Mesh:
    """
    Create nut mesh by loading from NUTS_BLEND_FILE and applying optional shape keys
    shape_param: Dict of {shape_key layer name: layer fac} to apply nut source meshes keys
                 Default vert locs are used as rest position
    """
    input_is_bm = isinstance(mesh, BMesh)
    if not input_is_bm:
        nut_bm = bmesh.new()
        nut_bm.from_mesh(mesh)
    else:
        nut_bm = mesh

    try:
        with bm_help.MeshReader(body_type, NUTS_BLEND_FILE) as mesh_reader:
            nut_bm.from_mesh(mesh_reader)
    except KeyError:
        print(f"Failed to find {body_type} in {NUTS_BLEND_FILE}")

    # Apply shape keys
    try:
        apply_shape_keys(nut_bm, shape_params)
    except KeyError:
        print(f"Failed to shape keys for nut {body_type}")

    # Apply scaling
    scaler = Vector((diameter, diameter, length))
    bmesh.ops.scale(nut_bm, vec=scaler, verts=nut_bm.verts[:])

    # Return
    if not input_is_bm:
        nut_bm.to_mesh(mesh)
        nut_bm.free()

    return mesh


def join_and_bridge_meshes(
    mesh_a: bpy.types.Mesh,
    mesh_b: bpy.types.Mesh,
    bridges: Optional[Iterable[tuple[str, str]]] = None,
    mesh_a_offset: Optional[Vector] = None,
    mesh_b_offset: Optional[Vector] = None,
    name: str = "combined",
    output_mesh: Optional[bpy.types.Mesh] = None,
) -> bpy.types.Mesh:
    """
    Join two meshes component through bridges defined by vertex attribute pairs
    Args:
        mesh_a: First Mesh
        mesh_b: Second Mesh
        mesh_a_offset = Optional translation to apply to mesh_a
        mesh_b_offset = Optional translation to apply to mesh_b
        bridges: pairs of vertex attributes, (mesh_a attrib, mesh_b attrib). Where vertex is attib == 1, vertex will be part of bridge between meshes
    """
    bm = bmesh.new()
    bm.from_mesh(mesh_a)

    # Create mesh_a identifying attrib and record min-max z ranges
    mesh_a_grp = bm.verts.layers.int.new("mesh_a")  # Idendity mesh_a attribs by value of 1 in this 
    for vert in bm.verts:
        vert[mesh_a_grp] = 1

    # Load mesh b 
    bm.from_mesh(mesh_b)
    is_mesh_a = lambda v: v[mesh_a_grp] == 1

    mesh_a_verts = list()
    mesh_b_verts = list()
    for vert in bm.verts:
        if is_mesh_a(vert):
            mesh_a_verts.append(vert)
        else:
            mesh_b_verts.append(vert)

    if mesh_a_offset:
        bmesh.ops.translate(bm, vec=mesh_a_offset, verts=mesh_a_verts)
    if mesh_b_offset:
        bmesh.ops.translate(bm, vec=mesh_b_offset, verts=mesh_b_verts)

    top_edges = bm.edges.layers.int["top_edges"]
    for edge in bm.edges:
        if edge[top_edges] == 1:
            edge.select_set(True)

    if bridges:
        # Get dict where bridge attribute pairs are the keys and values are an empty pair of iterbles in which to put layer members
        bridge_sets = dict()
        for layer_a, layer_b in bridges:
            bridge_sets[(bm.edges.layers.int[layer_a], bm.edges.layers.int[layer_b])] = (list(), list())

        # Populate bridge sets with their relevant edges
        for layer_pair in bridge_sets:
            layer_a, layer_b = layer_pair
            for edge in bm.edges:
                if edge[layer_a] == 1 and edge.verts[0][mesh_a_grp] == 1:
                    bridge_sets[layer_pair][0].append(edge)
                if edge[layer_b] == 1 and edge.verts[0][mesh_a_grp] == 0:
                    bridge_sets[layer_pair][1].append(edge)

        # Create bridges
        for edges_a, edges_b in bridge_sets.values():
            bmesh.ops.bridge_loops(bm, edges=edges_a + edges_b)

    mesh_a_grp = bm.verts.layers.int.remove(mesh_a_grp)

    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0001)

    if output_mesh:
        mesh = output_mesh
    else:
        mesh = bpy.data.meshes.new(name)


    bm.to_mesh(mesh)
    bm.free()
    return mesh

def create_nut() -> bpy.types.Mesh:
    """
    Just a placeholder
    """
    thread = create_thread(internal=True)
    nut_body = create_nut_body(
        shape_params={
            "param_a": 0.0,
            "param_b": 0.0,
        }
    )
    combined = join_and_bridge_meshes(
        nut_body,
        thread,
        bridges=(
            ("top_edges", "top_edges"),
            ("bottom_edges", "bottom_edges"),
        )
    )
    return combined


def add_shank(
    mesh: Union[BMesh, Mesh],
    length: float,
    runout_length: float = 0.0,
    runout_offset: float = 0.0,
    source_attrib_name: str = "top_edges",
    cap: bool = False
):
    input_is_bmesh = isinstance(mesh, BMesh)
    if input_is_bmesh:
        bm = mesh
    else:
        bm = bmesh.new()
        bm.from_mesh(mesh)

    top_edges_attrib = bm.edges.layers.int[source_attrib_name]
    init_top_edges = []
    for edge in bm.edges:
        if edge[top_edges_attrib] == 1:
            init_top_edges.append(edge)
            edge[top_edges_attrib] == 0  # Clear because will no longer be valid
    
    extrusion = bmesh.ops.extrude_edge_only(bm, edges=init_top_edges)['geom']
    typed_extrusion = bm_help.dict_by_type(extrusion)
    top_edges = typed_extrusion[BMEdge]
    top_verts = typed_extrusion[BMVert]
    bm_help.set_attib_values(bm.edges, top_edges_attrib, 0)

    if not runout_length > 0.0:
        bmesh.ops.translate(bm, vec=Vector((0, 0, length)), verts=top_verts)
    else:
        # Apply runout offset offset
        if abs(runout_offset) > 0.0:
            for vert in top_verts:
                init_length = vert.co.xy.length
                target_length = init_length + runout_offset
                length_scaler = target_length / init_length
                vert.co.xy = vert.co.xy * length_scaler

        # Runout extrusion
        bmesh.ops.translate(bm, vec=Vector((0, 0, runout_length)), verts=top_verts)

        # Shaft extrusion
        bm_help.set_attib_values(bm.edges, top_edges_attrib, 0)
        extrusion = bmesh.ops.extrude_edge_only(bm, edges=top_edges)['geom']
        typed_extrusion = bm_help.dict_by_type(extrusion)
        top_edges = typed_extrusion[BMEdge]
        top_verts = typed_extrusion[BMVert]
        bmesh.ops.translate(bm, vec=Vector((0, 0, length - runout_length)), verts=top_verts)

    if cap:
        bmesh.ops.holes_fill(bm, edges=top_edges)
    else:
        bm_help.set_attib_values(top_edges, top_edges_attrib, 1)
    
    if not input_is_bmesh:
        bm.to_mesh(mesh)


def bisect_for_print(
    mesh: Union[bpy.types.Mesh, bmesh.types.BMesh],
    # origin: Vector = Vector((0, 0, 0)),
    # normal: Vector = Vector((1, 0, 0)),
    spacing: float = 10.0,
    name: str = "bisected_mesh",
) -> bpy.types.Mesh:
    """
    Split mesh into two section for the purposes of 3d printing
    """
    if not isinstance(mesh, bmesh.types.BMesh):
        bm = bmesh.new()
        bm.from_mesh(mesh)
    else:
        bm = mesh

    # Create duplicate
    duplication = bmesh.ops.duplicate(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:])
    geom_side_a = duplication["geom_orig"]
    geom_side_b = duplication["geom"]
    side_a_verts = [i for i in geom_side_a if isinstance(i, bmesh.types.BMVert)]
    side_b_verts = [i for i in geom_side_b if isinstance(i, bmesh.types.BMVert)]

    # Apply pretransform
    loc_a = Vector((spacing, 0, 0))
    rot_a = Euler((0, pi / 2, 0))
    transform_a = Matrix.LocRotScale(loc_a, rot_a, None)
    bmesh.ops.transform(bm, matrix=transform_a, verts=side_a_verts)

    rot_b = Euler((0, -(pi / 2), 0))
    transform_b = Matrix.LocRotScale(-loc_a, rot_b, None)
    bmesh.ops.transform(bm, matrix=transform_b, verts=side_b_verts)

    geom = bm_help.all_geom(bm)
    cut_geom = bmesh.ops.bisect_plane(
        bm,
        geom=geom,
        plane_co=Vector((0, 0, 0)),
        plane_no=Vector((0, 0, 1)),
        clear_inner=True
    )

    cut = bm_help.dict_by_type(cut_geom["geom_cut"])
    edges = bm_help.shared_edges(cut[BMVert])
    fills = bmesh.ops.holes_fill(bm, edges=edges)
    bmesh.ops.triangulate(bm, faces=fills["faces"])
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.00001)

    if not isinstance(mesh, bmesh.types.BMesh):
        mesh = bpy.data.meshes.new(name)
        bm.to_mesh(mesh)
        bm.free()
        return mesh
    else:
        return bm


def create_bolt_thread(
    mesh: Union[BMesh, Mesh],
    thread_profile: ThreadProfile = ThreadProfile(),
    divisions: int = 32,
    reverse_thread: bool = False,
    chamfer: float = radians(15),
    chamfer_length: float = 0.1,
    chamfer_divisions: int = 0,
    cap_top: bool = True,
    name: str = "thread",
    chamfer_top: bool = False,
    smooth_top_termination: bool = True,
    smooth_top_to_minor: bool = False,
    # bm: Optional[bmesh.types.BMesh] = None,
) -> bpy.types.Mesh:
    """
    insead of returning a new mesh object
    Generate complex threading suitable for bolt usage
    """
    input_is_bmesh = isinstance(mesh, BMesh)
    if not input_is_bmesh:
        bm = bmesh.new()
        bm.from_mesh(mesh)
    else:
        bm = mesh

    create_thread(
        bm,
        thread_profile=thread_profile,
        divisions=divisions,
        reverse_thread=reverse_thread,
        internal=False,
        cap_bottom=True,
        smooth_top_termination=True,
        smooth_bottom_termination=True,
        terminate_outward=False,
    )

    layer = bm.edges.layers.int["top_edges"]
    top_edges = [edge for edge in bm.edges if edge[layer] == 1]

    # bm_help.interp_vert_mag_along_axis
    for edge in top_edges:
        # (xy.normalize * major_diameter) top edge verts
        # TODO: instead of smooth by top 
        for vert in edge.verts:
            # Set vert.co.xy length to thread_profile.major_diameter
            # vert.co.xy = vert.co.xy.normalized() * (thread_profile.major_diameter * 0.5)
            if smooth_top_to_minor:
                vert.co.xy = vert.co.xy.normalized() * (thread_profile.minor_diameter * 0.5)
            else:
                vert.co.xy = vert.co.xy.normalized() * (thread_profile.major_diameter * 0.5)
            
        # Clear edge attib values pending shaft addition
        if cap_top:
            edge[layer] = 0
    
    if cap_top:
        bmesh.ops.holes_fill(bm, edges=top_edges)

    # Chamfer base
    _chamfer_thread(
        bm,
        start_z=chamfer_length,
        end_z=0,
        major_radius=thread_profile.major_radius,
        divisions=chamfer_divisions,
        chamfer=chamfer
    )
    
    if smooth_top_termination:
        if smooth_top_to_minor:
            target_mag = thread_profile.minor_diameter * 0.5
        else:
            target_mag = thread_profile.major_diameter * 0.5
        start = (thread_profile.length - (thread_profile.pitch * 0.25))
        end = (thread_profile.length)
        bm_help.interp_vert_mag_along_axis(
            bm.verts,
            start_end=(start, end),
            target_mag=target_mag
        )

    if chamfer_top:
        _chamfer_thread(
            bm,
            start_z=thread_profile.length - chamfer_length,
            end_z=thread_profile.length,
            major_radius=thread_profile.major_radius,
            divisions=chamfer_divisions,
            chamfer=chamfer
        )

    if not input_is_bmesh:
        bm.to_mesh(mesh)
        bm.free()


def _chamfer_thread(
    bm: bmesh.types.BMesh,
    start_z,
    end_z,
    major_radius: float,
    # chamfer_length: float,
    divisions: int = 0,
    chamfer: float = radians(15),
) -> None:
    """ Chamfer value is an angle in radiands"""
    # chamfer_length: float,
    # start_z = chamfer_length
    # end_z = 0
    chamfer_length = abs(start_z - end_z)
    start_radius = major_radius
    end_radius = start_radius - (tan(chamfer) * chamfer_length)

    # Add chamfer divisions
    if divisions > 0:
        cut_norm = Vector((0, 0, 1))
        cut_loc = Vector((0, 0, 0))
        for cut_z in np.linspace(start_z, end_z, num=divisions):
            cut_loc.z = cut_z
            geom = bm.faces[:] + bm.edges[:]
            bmesh.ops.bisect_plane(
                bm, geom=geom, dist=0.0001, plane_co=cut_loc, plane_no=cut_norm
            )
    
    tolerance = 0.01
    in_range_min = lambda v: v.co.z >= min(start_z, end_z) - tolerance
    in_range_max = lambda v: v.co.z <= max(start_z, end_z) + tolerance
    vert_in_range = lambda v: in_range_min(v) and in_range_max(v)
    affected_verts = filter(vert_in_range, bm.verts)

    for vert in affected_verts:
        xy, z = vert.co.xy, vert.co.z
        init_mag = xy.length
        target_mag = map_range(z, (start_z, end_z), (init_mag, end_radius))
        vert.co.xy = xy.normalized() * target_mag


def trim_by_fac(bm: bmesh.types.BMesh, trim_fac: float = 0.0):
    """Mirrored mesh trimming through bisection and capping"""
    min_x_vert, max_x_vert = bm_help.min_max_verts(bm.verts, axis="x")
    min_x, max_x = min_x_vert.co.x, max_x_vert.co.x
    x_len = abs(min_x - max_x)
    trim_len = x_len * (1 - (trim_fac / 2))

    cut_locs = (Vector((min_x + trim_len, 0, 0)), Vector((max_x - trim_len, 0, 0)))
    cut_norms = (Vector((1, 0, 0)), Vector((-1, 0, 0)))
    for loc, norm in zip(cut_locs, cut_norms):
        geom = bm_help.bm_as_list(bm)
        trimmed = bmesh.ops.bisect_plane(
            bm, geom=geom, clear_outer=True, plane_co=loc, plane_no=norm
        )

        cut = bm_help.dict_by_type(trimmed["geom_cut"])
        if BMVert not in cut.keys():
            continue

        edges = bm_help.shared_edges(cut[BMVert])
        fills = bmesh.ops.holes_fill(bm, edges=edges)
        bmesh.ops.triangulate(bm, faces=fills["faces"])
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.00001)


# nut = create_nut()
# thread = create_thread_mesh(internal=True)

# bisected = bisect_mesh(nut, Vector((0, 0, 0)), Vector((1, 0, 0)))
# ob = bpy.data.objects.new('blah', object_data=bisected)
# bpy.context.collection.objects.link(ob)


# def create_nut(
#     bm: bmesh.types.BMesh,
#     profile: bmesh.types.BMesh,
#         "custom_thread_profile": PropertyMapping("Custom Profile", default=0),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#         "minor_diameter": PropertyMapping("Minor Diameter", default=1.2),
#         "crest_weight": PropertyMapping("Crest Weight", default=0.5),
#         "root_weight": PropertyMapping("Root Weight", default=0.5),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#
#     type_props = {
#         "pitch": PropertyMapping("Pitch", default=0.2),
#         "nut_type": PropertyMapping("Nut", default="HEX"),
#         "nut_diameter": PropertyMapping("Diameter", default=2.14),
#         "length": PropertyMapping("Length", default=1.8),
#         "nut_chamfer": PropertyMapping("Chamfer", min_val=0.001, default=1),
#         "thread_resolution": PropertyMapping("Thread Resolution", default=16),
#         # "major_diameter": PropertyMapping("Major Diameter", default=2),
#         "starts": PropertyMapping("Thread Starts", min_val=1, default=1),
#     }
#
#     general_props = {
#         # "thread_direction": PropertyMapping("Direction Prop B", default="RIGHT"),
#         "bisect": PropertyMapping("Bisect", default=False),
#         "triangulate": PropertyMapping("Triangulate", default=False),
#         "tolerance": PropertyMapping("Tolerance", default=0),prime
#         "scale": PropertyMapping("Scale", default=1),
#         "shade_smooth": PropertyMapping("Shade Smooth", default=False),
#     }
#
#     def create(self, mesh: Mesh) -> Mesh:
#         self._load_body()
#         body_geom = dict_by_type(bm_as_list(bm))
#         boundary_verts = [v for v in body_geom[BMVert] if v.is_boundary]
#         body_rim_top_verts, body_rim_bottom_verts = vert_axis_split(boundary_verts)
#         body_loop_top = shared_edges(body_rim_top_verts)
#         body_loop_bottom = shared_edges(body_rim_bottom_verts)
#
#         # Transform body
#         self._transform_body()
#
#         # Mesh Threads
#         body_geom = set(bm_as_list(bm))
#         thread_bm = self._mesh_nut_threads()
#         temp_mesh = bpy.data.meshes.new("temp")
#         thread_bm.to_mesh(temp_mesh)
#         thread_bm.free()
#         bm.from_mesh(temp_mesh)
#         bpy.data.meshes.remove(temp_mesh)
#         thread_geom = set(bm_as_list(bm)) - body_geom
#         thread_geom = dict_by_type(thread_geom)
#
#         # Identity Thread boundary loops
#         boundary_verts = [v for v in thread_geom[BMVert] if v.is_boundary]
#         # for v in boundary_verts:
#         #     v.co.z += 1
#
#         thread_rim_top, thread_rim_bottom = vert_axis_split(boundary_verts, 0.001)
#         thread_loop_top = shared_edges(thread_rim_top)
#         thread_loop_bottom = shared_edges(thread_rim_bottom)
#
#         # Smooth Thread Terminations
#         self._smooth_thread_terminations(thread_geom[BMVert])
#
#         # Bridge loop and body
#         bridge_a = thread_loop_top + body_loop_top
#         bridge_b = thread_loop_bottom + body_loop_bottom
#         for edges in (bridge_a, bridge_b):
#             bmesh.ops.bridge_loops(bm, edges=edges)
#
#         # Bisect mesh
#         if self.bisect:
#             self._bisect()
#
#         if self.triangulate:
#             bmesh.ops.triangulate(bm, faces=bm.faces)
#
#         # Apply tolerance transforms
#         # if self.props.tolerance != 0:
#         #     self._adjust_tolerance()
#
#         # Apply scale
#         if self.scale != 0.0:
#             self._scale()
#
#         bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
#
#         for f in bm.faces:
#             f.smooth = shade_smooth
#
#         bm.to_mesh(mesh)
#
#     def _smooth_thread_terminations(self, thread_verts: List[BMVert]) -> None:
#         target_radius = self.props.major_diameter * 0.55 - (self.props.tolerance * 0.5)
#         affected_distance = self.props.length * 0.1
#         # From no effect to full (target_radius)
#         top_range = (self.props.length - affected_distance, self.props.length)
#         bottom_range = (affected_distance, 0)
#
#         for vert in thread_verts:
#             xy, z = vert.co.xy, vert.co.z
#             if z <= bottom_range[0]:
#                 effect_range = bottom_range
#             elif z >= top_range[0]:
#                 effect_range = top_range
#             else:
#                 continue
#             init_mag = xy.length
#             target_mag = map_range(z, effect_range, (init_mag, target_radius))
#             vert.co.xy = xy.normalized() * target_mag
#
#     def _bisect(self) -> None:
#         # TODO: Inconsistent mesh placement
#         geom = bmesh_helpers.bm_as_list(bm)
#         duplicate = bmesh.ops.duplicate(bm, geom=geom)
#         front = dict_by_type(duplicate["geom_orig"])
#         back = dict_by_type(duplicate["geom"])
#
#         z_offset = -(self.props.length + self.props.head_length) / 2
#         height_offset = Vector((0, 0, z_offset))
#         bmesh.ops.translate(bm, vec=height_offset, verts=bm.verts)
#
#         x_offset = self.props.length
#         loc_offset = Vector((0, self.props.length, 0))
#         front_rot = Euler((radians(90), 0, 0)).to_matrix()
#         cent = Vector.Fill(3, 0)
#         bmesh.ops.rotate(bm, cent=cent, verts=front[BMVert], matrix=front_rot)
#         bmesh.ops.translate(bm, vec=loc_offset, verts=front[BMVert])
#
#         back_rot = Euler((radians(-90), 0, 0)).to_matrix()
#         bmesh.ops.rotate(bm, cent=cent, verts=back[BMVert], matrix=back_rot)
#         bmesh.ops.translate(bm, vec=-loc_offset, verts=back[BMVert])
#
#         geom = bmesh_helpers.bm_as_list(bm)
#         co, no = Vector.Fill(3, 0), Vector((0, 0, -1))
#         trimmed = bmesh.ops.bisect_plane(
#             bm, geom=geom, clear_outer=True, plane_co=co, plane_no=no
#         )
#
#         cut = dict_by_type(trimmed["geom_cut"])
#         edges = bmesh_helpers.shared_edges(cut[BMVert])
#         fills = bmesh.ops.holes_fill(bm, edges=edges)
#         bmesh.ops.triangulate(bm, faces=fills["faces"])
#         bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.00001)
#
#     def _transform_body(self) -> None:
#         # Set Chamfer
#         top_verts, bottom_verts = vert_axis_split(bm.verts)
#         bmesh.ops.translate(bm, vec=Vector((0, 0, -1)), verts=top_verts)
#         scaler = Vector((1, 1, self.props.nut_chamfer))
#         bmesh.ops.scale(bm, vec=scaler, verts=top_verts + bottom_verts)
#         # Set Length
#         bmesh.ops.translate(
#             bm, vec=Vector((0, 0, self.props.length)), verts=top_verts
#         )
#
#         # Set Radius
#         scaler = Vector((self.props.nut_diameter, self.props.nut_diameter, 1))
#         bmesh.ops.scale(bm, vec=scaler, verts=top_verts + bottom_verts)
#
#     def _load_body(self) -> None:
#         with MeshReader(self.props.nut_type, NUTS_FILE) as mesh_loader:
#             bm.from_mesh(mesh_loader)
#
#     def _mesh_nut_threads(self):
#         """
#         Create mesh threads in bm
#         Returns: Tuple of bottom, top geom dicts whose keys are geometry types
#         """
#         thread_bm = bmesh.new()
#         vert_layers = FastenerVertLayers(thread_bm)
#
#         if self.props.custom_thread_profile:
#             profile = thread_profiles.Custom(
#                 self.props.pitch,
#                 self.props.length - self.props.tolerance,
#                 self.props.minor_diameter - self.props.tolerance,
#                 self.props.major_diameter - self.props.tolerance,
#                 self.props.starts,
#                 self.props.root_weight,
#                 self.props.crest_weight,
#             )
#         else:
#             profile = thread_profiles.ISO_68_1(
#                 self.props.pitch,
#                 self.props.length - self.props.tolerance,
#                 self.props.major_diameter - self.props.tolerance,
#                 self.props.starts,
#                 self.props.thread_angle,
#             )
#
#         # Create profile verts
#         profile_points = deque(profile.points)
#         profile_verts = []
#         first_coord = profile_points.pop()
#         prev_vert = thread_bm.verts.new(_np2d_to_v3d(first_coord))
#         profile_verts.append(prev_vert)
#         while profile_points:
#             co = _np2d_to_v3d(profile_points.pop())
#             new_vert = thread_bm.verts.new(co)
#             thread_bm.edges.new((prev_vert, new_vert))
#             prev_vert = new_vert
#             profile_verts.append(new_vert)
#
#         # Assign vert feature type to layer
#         # List is reversed because thread points are processed LIFO
#         for index, vert in enumerate(reversed(thread_bm.verts[:])):
#             if profile.feature_by_index(index) == "crest":
#                 vert[vert_layers.thread_crests] = 1
#             else:
#                 vert[vert_layers.thread_roots] = 1
#
#         start_verts = profile_verts
#         # start_profile = start_verts + bm.edges[:]
#         start_profile = shared_edges(start_verts)
#         steps = self.props.thread_resolution
#         step_z = self.props.pitch * self.props.starts / steps
#         axis = Vector((0, 0, 1))
#         dvec = Vector((0, 0, step_z))
#         # if self.props.thread_direction == "RIGHT":
#         angle = radians(360)
#         # else:
#         #     angle = radians(-360)
#
#         spun = bmesh.ops.spin(
#             thread_bm,
#             geom=start_profile,
#             angle=angle,
#             steps=steps,
#             # use_merge=True,
#             dvec=dvec,
#             axis=axis,
#         )
#
#         end_verts = dict_by_type(spun["geom_last"])[BMVert]
#         merge_dist = 0.001
#         boundary_verts = [
#             vert for vert in chain(start_verts, end_verts) if vert.is_boundary
#         ]
#         bmesh.ops.remove_doubles(thread_bm, verts=boundary_verts, dist=merge_dist)
#
#         # Cut Bottom
#         geom = bmesh_helpers.bm_as_list(thread_bm)
#         loc = Vector((0, 0, self.props.pitch * self.props.starts))
#         norm = Vector((0, 0, -1))
#         result = bmesh_helpers.trim(thread_bm, geom, loc=loc, norm=norm, cap=False)
#
#         # Floor thread mesh
#         min_z = bmesh_helpers.min_vert(thread_bm.verts[:], "z").co.z
#         bmesh.ops.translate(
#             thread_bm, vec=Vector((0, 0, -min_z)), verts=thread_bm.verts
#         )
#
#         # Cut Top
#         geom = bmesh_helpers.bm_as_list(thread_bm)
#         loc = Vector((0, 0, self.props.length))
#         result = bmesh_helpers.trim(thread_bm, geom, loc=loc, norm=Vector((0, 0, 1)))
#         bmesh.ops.reverse_faces(thread_bm, faces=thread_bm.faces)
#
#         # Tri divide ngons
#         ngons = [f for f in bm.faces if len(f.edges[:]) > 4]
#         bmesh.ops.triangulate(bm, faces=ngons)
#
#         return thread_bm
#
#
# @dataclass
# class Bolt(Fastener):
#     props: FastenerProps
#     type = "BOLT"
#     heads = HEADS
#     drivers = DRIVERS
#
#     custom_thread_props = {
#         "custom_thread_profile": PropertyMapping("Custom Profile", default=0),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#         "minor_diameter": PropertyMapping("Minor Diameter", default=1.2),
#         "crest_weight": PropertyMapping("Crest Weight", default=0.5),
#         "root_weight": PropertyMapping("Root Weight", default=0.5),
#     }
#
#     standard_thread_props = {
#         "custom_thread_profile": PropertyMapping("Custom Profile", default=0),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#     }
#
#     type_props = {
#         "pitch": PropertyMapping("Pitch", default=0.2),
#         "length": PropertyMapping("Length", default=4),
#         "thread_resolution": PropertyMapping("Thread Resolution", default=16),
#         "starts": PropertyMapping("Thread Starts", min_val=1, default=1),
#         "shank_length": PropertyMapping("Shank Length", min_val=0, default=1),
#         "chamfer": PropertyMapping("Chamfer", min_val=0, default=radians(15)),
#         "chamfer_length": PropertyMapping("Chamfer Length", min_val=0, default=0.1),
#         "chamfer_divisions": PropertyMapping("Chamfer Divisions", min_val=0, default=0),
#         "runout_length": PropertyMapping("Runout Length", min_val=0, default=0),
#         "runout_offset": PropertyMapping("Runout Offset", default=0),
#     }
#
#     general_props = {
#         # "thread_direction": PropertyMapping("Direction Prop B", default="RIGHT"),
#         "bisect": PropertyMapping("Bisect", default=False),
#         "trim": PropertyMapping("Trim", default=0),
#         "triangulate": PropertyMapping("Triangulate", default=False),
#         "bisect": PropertyMapping("Bisect", default=False),
#         "tolerance": PropertyMapping("Tolerance", default=0),
#         "scale": PropertyMapping("Scale", default=1),
#         "shade_smooth": PropertyMapping("Shade Smooth", default=False),
#     }
#
#     def create(self, mesh: Mesh):
#         """Create new fastener in mesh datablock"""
#         has_thread = self.props.shank_length < self.props.length
#         if has_thread:
#             threads_bottom, threads_top = self._mesh_threads()
#
#             top_edges = threads_top[BMEdge]
#             bottom_edges = threads_bottom[BMEdge]
#             top_verts = threads_top[BMVert]
#
#             # Round thread top termination (vanishing cone)
#             top_verts = bmesh_helpers.polar_sort_verts(top_verts)
#             for vert in top_verts:
#                 vert.co.z = (
#                     self.props.length - self.props.shank_length - self.props.tolerance
#                 )
#
#             # Smooth Thread termination
#             end = self.props.length - self.props.shank_length - self.props.tolerance
#             start = end - (self.props.pitch / 2)
#             start_end = start, end
#             bmesh_helpers.interp_vert_mag_along_axis(
#                 bm.verts,
#                 start_end,
#                 self.major_radius,
#             )
#
#         else:  # Only shank
#             circle = bmesh.ops.create_circle(
#                 bm, radius=self.major_radius, segments=self.props.thread_resolution
#             )
#             top_edges = bmesh_helpers.shared_edges(circle["verts"])
#             bottom_edges = top_edges
#             bmesh.ops.triangle_fill(bm, use_dissolve=True, edges=bottom_edges)
#
#         # Create Shank
#         if self.props.shank_length != 0:
#             top_edges = self._create_shank(top_edges)
#
#         # Create Head
#         if self.props.head_type != "NONE":
#             # Create and merge head mesh
#             head_bm = self._create_head()
#             head_verts, head_faces = bmesh_helpers.merge_bmesh(head_bm, bm)
#
#             # Set head height
#             offset = Vector((0, 0, self.props.length - (self.props.tolerance * 2)))
#             bmesh.ops.translate(bm, vec=offset, verts=head_verts)
#
#             head_opening = filter(lambda v: v.is_boundary, head_verts)
#             connection_loop = bmesh_helpers.shared_edges(head_opening)
#
#             # Join shank/thread to head
#             open_loops = connection_loop + top_edges
#             # bm, edges=open_loops, use_pairs=True,
#             # TODO: Fix this
#             bmesh.ops.bridge_loops(
#                 bm,
#                 edges=open_loops,
#             )
#         else:
#             bmesh.ops.triangle_fill(bm, use_dissolve=True, edges=top_edges)
#
#         if self.props.chamfer_length > 0:
#             self._chamfer()
#
#         if self.props.driver_type != "NONE":
#             driver_bm = self._create_driver()
#             bm = boolean_bm(bm, driver_bm, xform=self._driver_xform)
#             driver_bm.free()
#
#         if self.props.triangulate:
#             bmesh.ops.triangulate(bm, faces=bm.faces)
#
#         if self.props.trim != 0:
#             self.trim()
#
#         # if self.props.tolerance != 0:
#         #     self._adjust_tolerance()
#
#         if self.props.bisect:
#             self._bisect()
#
#         if self.props.scale != 0.0:
#             self._scale()
#
#         bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
#
#         for f in bm.faces:
#             f.smooth = self.props.shade_smooth
#
#         bm.to_mesh(mesh)
#
#     def _mesh_threads(self):
#         """
#         Create mesh threads in bm
#         Returns: Tuple of bottom, top geom dicts whose keys are geometry types
#         """
#
#         if self.props.custom_thread_profile:
#             profile = thread_profiles.Custom(
#                 self.props.pitch,
#                 self.props.length - self.props.tolerance,
#                 self.props.minor_diameter - self.props.tolerance,
#                 self.props.major_diameter - self.props.tolerance,
#                 self.props.starts,
#                 self.props.root_weight,
#                 self.props.crest_weight,
#                 # tolerance=self.props.tolerance,
#             )
#         else:
#             profile = thread_profiles.ISO_68_1(
#                 self.props.pitch,
#                 self.props.length - self.props.tolerance,
#                 self.props.major_diameter - self.props.tolerance,
#                 self.props.starts,
#                 self.props.thread_angle,
#                 # tolerance=self.props.tolerance,
#             )
#
#         profile_points = deque(profile.points)
#         first_coord = profile_points.pop()
#         prev_vert = bm.verts.new(_np2d_to_v3d(first_coord))
#
#         # Create rest of profile verts
#         while profile_points:
#             # Create new vert
#             co = _np2d_to_v3d(profile_points.pop())
#             new_vert = bm.verts.new(co)
#
#             # Create edge
#             bm.edges.new((prev_vert, new_vert))
#
#             # Assign new to last for next iteration
#             prev_vert = new_vert
#
#         # Assign vert feature type to layer
#         # List is revered because thread points are processed LIFO
#         for index, vert in enumerate(reversed(bm.verts[:])):
#             if profile.feature_by_index(index) == "crest":
#                 vert[self.vert_layers.thread_crests] = 1
#             else:
#                 vert[self.vert_layers.thread_roots] = 1
#
#         start_verts = bm.verts[:]
#         start_profile = start_verts + bm.edges[:]
#         steps = self.props.thread_resolution
#         step_z = self.props.pitch * self.props.starts / steps
#         axis = Vector((0, 0, 1))
#         dvec = Vector((0, 0, step_z))
#
#         # NOTE: Not used
#         # if self.props.thread_direction == "RIGHT":
#         angle = radians(360)
#         # else:
#         #     angle = radians(-360)
#
#         spun = bmesh.ops.spin(
#             bm,
#             geom=start_profile,
#             angle=angle,
#             steps=steps,
#             dvec=dvec,
#             axis=axis,
#         )
#
#         end_verts = dict_by_type(spun["geom_last"])[BMVert]
#         merge_dist = 0.001
#         boundary_verts = [
#             vert for vert in chain(start_verts, end_verts) if vert.is_boundary
#         ]
#         bmesh.ops.remove_doubles(bm, verts=boundary_verts, dist=merge_dist)
#
#         # Cut Bottom
#         geom = bmesh_helpers.bm_as_list(bm)
#         loc = Vector((0, 0, self.props.pitch * self.props.starts))
#         norm = Vector((0, 0, -1))
#         cut_merge_dist = 0.001
#         result = bmesh_helpers.trim(
#             bm, geom, dist=cut_merge_dist, loc=loc, norm=norm, cap=True
#         )
#         thread_bottom = dict_by_type(result["geom_cut"])
#
#         # Floor thread mesh
#         min_z = bmesh_helpers.min_vert(bm.verts[:], "z").co.z
#         for v in bm.verts[:]:
#             v.co.z -= min_z
#
#         # Cut Top
#         geom = bmesh_helpers.bm_as_list(bm)
#         loc = Vector(
#             (0, 0, self.props.length - self.props.shank_length - self.props.tolerance)
#         )
#         norm = Vector((0, 0, 1))
#         merge_dist = 0.01
#
#         thread_top = None
#
#         result = bmesh.ops.bisect_plane(
#             bm,
#             geom=geom,
#             plane_co=loc,
#             plane_no=norm,
#             dist=merge_dist,
#             clear_outer=True,
#         )
#
#         thread_top = dict_by_type(result["geom_cut"])
#
#         # Tri divide ngons
#         ngons = [f for f in bm.faces if len(f.edges[:]) > 4]
#         bmesh.ops.triangulate(bm, faces=ngons)
#
#         # bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=merge_dist)
#
#         return thread_bottom, thread_top
#
#     @property
#     def _driver_xform(self):
#         boolean_buffer = 0.001
#         z = (self.props.length - self.props.tolerance) + boolean_buffer
#         if self.props.head_type != "NONE":
#             z += self.props.head_length - self.props.tolerance
#         location = Matrix.Translation((0, 0, z))
#         rotation = Matrix.Rotation(radians(180), 4, "X")
#         # scale = Matrix.Scale(self.props.driver_diameter, 4)
#         return location @ rotation
#
#     def _chamfer(self):
#         start_z = self.props.chamfer_length
#         end_z = 0
#         start_radius = self.major_radius
#         end_radius = start_radius - (
#             tan(self.props.chamfer) * self.props.chamfer_length
#         )
#
#         # Add chamfer divisions
#         extra_divisions = self.props.chamfer_divisions
#         if extra_divisions > 0:
#             cut_norm = Vector((0, 0, 1))
#             cut_loc = Vector((0, 0, 0))
#             for cut_z in np.linspace(start_z, end_z, num=extra_divisions):
#                 cut_loc.z = cut_z
#                 geom = bm.faces[:] + bm.edges[:]
#                 bmesh.ops.bisect_plane(
#                     bm, geom=geom, dist=0.0001, plane_co=cut_loc, plane_no=cut_norm
#                 )
#
#         affected_verts = filter(lambda v: v.co.z < start_z, bm.verts)
#         for vert in affected_verts:
#             xy, z = vert.co.xy, vert.co.z
#             init_mag = xy.length
#             target_mag = map_range(z, (start_z, end_z), (init_mag, end_radius))
#             vert.co.xy = xy.normalized() * target_mag
#
#     def _bisect(self) -> None:
#         geom = bmesh_helpers.bm_as_list(bm)
#         duplicate = bmesh.ops.duplicate(bm, geom=geom)
#         front = dict_by_type(duplicate["geom_orig"])
#         back = dict_by_type(duplicate["geom"])
#
#         z_offset = -(self.props.length + self.props.head_length) / 2
#         x_offset = max(self.props.head_diameter, self.props.major_diameter / 2 * 1.1)
#         loc_offset = Vector((x_offset, 0, 0))
#         height_offset = Vector((0, 0, z_offset))
#         bmesh.ops.translate(bm, vec=height_offset, verts=bm.verts)
#
#         front_rot = Euler((radians(90), 0, 0)).to_matrix()
#         cent = Vector.Fill(3, 0)
#         bmesh.ops.rotate(bm, cent=cent, verts=front[BMVert], matrix=front_rot)
#         bmesh.ops.translate(bm, vec=loc_offset, verts=front[BMVert])
#
#         back_rot = Euler((radians(-90), 0, 0)).to_matrix()
#         bmesh.ops.rotate(bm, cent=cent, verts=back[BMVert], matrix=back_rot)
#         bmesh.ops.translate(bm, vec=-loc_offset, verts=back[BMVert])
#
#         geom = bmesh_helpers.bm_as_list(bm)
#         co, no = Vector.Fill(3, 0), Vector((0, 0, -1))
#         trimmed = bmesh.ops.bisect_plane(
#             bm, geom=geom, clear_outer=True, plane_co=co, plane_no=no
#         )
#
#         cut = dict_by_type(trimmed["geom_cut"])
#         edges = bmesh_helpers.shared_edges(cut[BMVert])
#         fills = bmesh.ops.holes_fill(bm, edges=edges)
#         bmesh.ops.triangulate(bm, faces=fills["faces"])
#         bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.00001)
#
#     def _create_head(self) -> BMesh:
#         # Create head mesh, apply modifiers and remove
#         head: FastenerHead = self.heads[self.props.head_type](self.props)
#         head.apply_transforms()
#         return head.bm
#
#     def _create_driver(self) -> BMesh:
#         driver = self.drivers[self.props.driver_type](self.props)
#         driver.apply_transforms()
#         return driver.bm
#
#
# @dataclass
# class ThreadedRod(Fastener):
#     props: FastenerProps
#     type = "THREADED_ROD"
#
#     custom_thread_props = {
#         "custom_thread_profile": PropertyMapping("Custom Profile", default=0),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#         "minor_diameter": PropertyMapping("Minor Diameter", default=1.2),
#         "crest_weight": PropertyMapping("Crest Weight", default=0.5),
#         "root_weight": PropertyMapping("Root Weight", default=0.5),
#     }
#
#     standard_thread_props = {
#         "custom_thread_profile": PropertyMapping("Custom Profile", default=0),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#     }
#
#     type_props = {
#         "pitch": PropertyMapping("Pitch", default=0.2),
#         "length": PropertyMapping("Length", default=4),
#         "thread_resolution": PropertyMapping("Thread Resolution", default=16),
#         "starts": PropertyMapping("Thread Starts", min_val=1, default=1),
#         "chamfer": PropertyMapping("Chamfer", min_val=0, default=radians(15)),
#         "chamfer_length": PropertyMapping("Chamfer Length", min_val=0, default=0.1),
#         "chamfer_divisions": PropertyMapping("Chamfer Divisions", min_val=0, default=0),
#     }
#
#     general_props = {
#         # "thread_direction": PropertyMapping("Direction Prop B", default="RIGHT"),
#         "bisect": PropertyMapping("Bisect", default=False),
#         "trim": PropertyMapping("Trim", default=0),
#         "triangulate": PropertyMapping("Triangulate", default=False),
#         "bisect": PropertyMapping("Bisect", default=False),
#         "tolerance": PropertyMapping("Tolerance", default=0),
#         "scale": PropertyMapping("Scale", default=1),
#         "shade_smooth": PropertyMapping("Shade Smooth", default=False),
#     }
#
#     def create(self, mesh: Mesh):
#         """Create new fastener in mesh datablock"""
#         threads_bottom, threads_top = self._mesh_threads()
#
#         top_edges = threads_top[BMEdge]
#         bottom_edges = threads_bottom[BMEdge]
#         top_verts = threads_top[BMVert]
#
#         # print(len(top_edges))
#         # bounding_edges = [edge for edge in bm.edges if edge.is_boundary]
#         # top_boundary = [edge for edge in bounding_edges if edge not in bottom_edges]
#
#         # Round thread top termination (vanishing cone)
#         top_verts = bmesh_helpers.polar_sort_verts(top_verts)
#
#         # Create Head
#         bmesh.ops.triangle_fill(bm, use_dissolve=True, edges=top_edges)
#         # bmesh.ops.edgeloop_fill(bm, edges=top_boundary)
#
#         if self.props.chamfer_length > 0:
#             self._chamfer()
#
#         if self.props.triangulate:
#             bmesh.ops.triangulate(bm, faces=bm.faces)
#
#         if self.props.trim != 0:
#             self.trim()
#
#         # if self.props.tolerance != 0:
#         #     self._adjust_tolerance()
#
#         if self.props.bisect:
#             self._bisect()
#
#         if self.props.scale != 0.0:
#             self._scale()
#
#         bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
#
#         for f in bm.faces:
#             f.smooth = self.props.shade_smooth
#
#         bm.to_mesh(mesh)
#
#     def _mesh_threads(self):
#         """
#         Create mesh threads in bm
#         Returns: Tuple of bottom, top geom dicts whose keys are geometry types
#         """
#
#         def _np2d_to_v3d(coord):
#             """[a,b] np to [b, 0, a] vector"""
#             return Vector((coord[1], 0, coord[0]))
#
#         if self.props.custom_thread_profile:
#             profile = thread_profiles.Custom(
#                 self.props.pitch,
#                 self.props.length,
#                 self.props.minor_diameter - self.props.tolerance,
#                 self.props.major_diameter - self.props.tolerance,
#                 self.props.starts,
#                 self.props.root_weight,
#                 self.props.crest_weight,
#                 # tolerance=self.props.tolerance,
#             )
#         else:
#             profile = thread_profiles.ISO_68_1(
#                 self.props.pitch,
#                 self.props.length - self.props.tolerance,
#                 self.props.major_diameter - self.props.tolerance,
#                 self.props.starts,
#                 self.props.thread_angle,
#                 # tolerance=self.props.tolerance,
#             )
#
#         profile_points = deque(profile.points)
#         first_coord = profile_points.pop()
#         prev_vert = bm.verts.new(_np2d_to_v3d(first_coord))
#
#         # Create rest of profile verts
#         while profile_points:
#             # Create new vert
#             co = _np2d_to_v3d(profile_points.pop())
#             new_vert = bm.verts.new(co)
#
#             # Create edge
#             bm.edges.new((prev_vert, new_vert))
#
#             # Assign new to last for next iteration
#             prev_vert = new_vert
#
#         # Assign vert feature type to layer
#         # List is revered because thread points are processed LIFO
#         for index, vert in enumerate(reversed(bm.verts[:])):
#             if profile.feature_by_index(index) == "crest":
#                 vert[self.vert_layers.thread_crests] = 1
#             else:
#                 vert[self.vert_layers.thread_roots] = 1
#
#         start_verts = bm.verts[:]
#         start_profile = start_verts + bm.edges[:]
#         steps = self.props.thread_resolution
#         step_z = self.props.pitch * self.props.starts / steps
#         axis = Vector((0, 0, 1))
#         dvec = Vector((0, 0, step_z))
#
#         # NOTE: Not used
#         # if self.props.thread_direction == "RIGHT":
#         angle = radians(360)
#         # else:
#         #     angle = radians(-360)
#
#         spun = bmesh.ops.spin(
#             bm,
#             geom=start_profile,
#             angle=angle,
#             steps=steps,
#             dvec=dvec,
#             axis=axis,
#         )
#
#         end_verts = dict_by_type(spun["geom_last"])[BMVert]
#         merge_dist = 0.0001
#         boundary_verts = [
#             vert for vert in chain(start_verts, end_verts) if vert.is_boundary
#         ]
#         bmesh.ops.remove_doubles(bm, verts=boundary_verts, dist=merge_dist)
#
#         # Cut Bottom
#         geom = bmesh_helpers.bm_as_list(bm)
#         loc = Vector((0, 0, self.props.pitch * self.props.starts))
#         norm = Vector((0, 0, -1))
#         cut_merge_dist = 0.001
#         result = bmesh_helpers.trim(
#             bm, geom, dist=cut_merge_dist, loc=loc, norm=norm, cap=True
#         )
#         thread_bottom = dict_by_type(result["geom_cut"])
#
#         # Floor thread mesh
#         min_z = bmesh_helpers.min_vert(bm.verts[:], "z").co.z
#         for v in bm.verts[:]:
#             v.co.z -= min_z
#
#         # Cut Top
#         geom = bmesh_helpers.bm_as_list(bm)
#         loc = Vector((0, 0, self.props.length))
#         norm = Vector((0, 0, 1))
#         # merge_dist = 0.01
#         # result = bmesh_helpers.trim(bm, geom, dist=merge_dist, loc=loc, norm=norm)
#         # bmesh.ops.triangulate(bm, faces=bm.faces)
#
#         result = bmesh.ops.bisect_plane(
#             bm,
#             geom=geom,
#             plane_co=loc,
#             plane_no=norm,
#             # dist=merge_dist,
#             clear_outer=True,
#         )
#
#         thread_top = dict_by_type(result["geom_cut"])
#
#         return thread_bottom, thread_top
#
#     def _chamfer(self):
#         def _apply_chamfer(start_z, end_z):
#             start_radius = self.major_radius
#             end_radius = start_radius - (
#                 tan(self.props.chamfer) * self.props.chamfer_length
#             )
#
#             # Add chamfer divisions
#             extra_divisions = self.props.chamfer_divisions
#             if extra_divisions > 0:
#                 cut_norm = Vector((0, 0, 1))
#                 cut_loc = Vector((0, 0, 0))
#                 for cut_z in np.linspace(start_z, end_z, num=extra_divisions):
#                     cut_loc.z = cut_z
#                     geom = bm.faces[:] + bm.edges[:]
#                     bmesh.ops.bisect_plane(
#                         bm,
#                         geom=geom,
#                         dist=0.0001,
#                         plane_co=cut_loc,
#                         plane_no=cut_norm,
#                     )
#
#             min_z, max_z = sorted((start_z, end_z))
#             value_in_range = lambda v: all((v.co.z >= min_z, v.co.z <= max_z))
#             affected_verts = filter(value_in_range, bm.verts)
#             for vert in affected_verts:
#                 xy, z = vert.co.xy, vert.co.z
#                 init_mag = xy.length
#                 target_mag = map_range(z, (start_z, end_z), (init_mag, end_radius))
#                 vert.co.xy = xy.normalized() * target_mag
#
#         chamfer_len = self.props.chamfer_length
#         bottom_range = (chamfer_len, 0)
#         top_range = (self.props.length - chamfer_len, self.props.length)
#         _apply_chamfer(*bottom_range)
#         _apply_chamfer(*top_range)
#
#     def _bisect(self) -> None:
#         geom = bmesh_helpers.bm_as_list(bm)
#         duplicate = bmesh.ops.duplicate(bm, geom=geom)
#         front = dict_by_type(duplicate["geom_orig"])
#         back = dict_by_type(duplicate["geom"])
#
#         z_offset = -(self.props.length + self.props.head_length) / 2
#         x_offset = max(self.props.head_diameter, self.props.major_diameter / 2 * 1.1)
#         loc_offset = Vector((x_offset, 0, 0))
#         height_offset = Vector((0, 0, z_offset))
#         bmesh.ops.translate(bm, vec=height_offset, verts=bm.verts)
#
#         front_rot = Euler((radians(90), 0, 0)).to_matrix()
#         cent = Vector.Fill(3, 0)
#         bmesh.ops.rotate(bm, cent=cent, verts=front[BMVert], matrix=front_rot)
#         bmesh.ops.translate(bm, vec=loc_offset, verts=front[BMVert])
#
#         back_rot = Euler((radians(-90), 0, 0)).to_matrix()
#         bmesh.ops.rotate(bm, cent=cent, verts=back[BMVert], matrix=back_rot)
#         bmesh.ops.translate(bm, vec=-loc_offset, verts=back[BMVert])
#
#         geom = bmesh_helpers.bm_as_list(bm)
#         co, no = Vector.Fill(3, 0), Vector((0, 0, -1))
#         trimmed = bmesh.ops.bisect_plane(
#             bm, geom=geom, clear_outer=True, plane_co=co, plane_no=no
#         )
#
#         cut = dict_by_type(trimmed["geom_cut"])
#         edges = bmesh_helpers.shared_edges(cut[BMVert])
#         fills = bmesh.ops.holes_fill(bm, edges=edges)
#         bmesh.ops.triangulate(bm, faces=fills["faces"])
#         bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.00001)
#
#     # @property
#     # def major_radius(self) -> float:
#     #     return self.props.major_diameter / 2 - self.props.tolerance
#
#
# @dataclass
# class Screw(Fastener):
#     props: FastenerProps
#     type = "SCREW"
#     heads = HEADS
#     drivers = DRIVERS
#     custom_thread_props = None
#
#     type_props = {
#         "pitch": PropertyMapping("Pitch", default=0.2),
#         "length": PropertyMapping("Length", default=4),
#         "thread_resolution": PropertyMapping("Thread Resolution", default=16),
#         "major_diameter": PropertyMapping("Major Diameter", default=2),
#         "starts": PropertyMapping("Thread Starts", min_val=1, default=1),
#         "shank_length": PropertyMapping("Shank Length", min_val=0, default=1),
#         # "chamfer": PropertyMapping("Chamfer", min_val=0, default=radians(15)),
#         # "chamfer_length": PropertyMapping("Chamfer Length", min_val=0, default=0.1),
#         # "chamfer_divisions": PropertyMapping("Chamfer Divisions", min_val=0, default=0),
#         "screw_taper_factor": PropertyMapping("Taper Factor", min_val=0, default=0.1),
#         "runout_length": PropertyMapping("Runout Length", min_val=0, default=0),
#         "runout_offset": PropertyMapping("Runout Offset", default=0),
#     }
#
#     general_props = {
#         # "thread_direction": PropertyMapping("Direction Prop B", default="RIGHT"),
#         "triangulate": PropertyMapping("Triangulate", default=False),
#         "bisect": PropertyMapping("Bisect", default=False),
#         "tolerance": PropertyMapping("Tolerance", default=0),
#         "scale": PropertyMapping("Scale", default=1),
#         "shade_smooth": PropertyMapping("Shade Smooth", default=False),
#     }
#
#     def create(self, mesh: Mesh):
#         """Create new fastener in mesh datablock"""
#         # Create Threads
#         if self.props.shank_length < self.props.length:
#             threads_bottom, threads_top = self._mesh_threads()
#             top_edges = threads_top[BMEdge]
#             bottom_edges = threads_bottom[BMEdge]
#             top_verts = threads_top[BMVert]
#
#             # Round thread top termination (vanishing cone)
#             top_verts = bmesh_helpers.polar_sort_verts(top_verts)
#             bmesh_helpers.verts_to_circle(top_verts, self.major_radius)
#             for vert in top_verts:
#                 vert.co.z = self.props.length - self.props.shank_length
#
#             # Smooth Thread termination
#             end = self.props.length - self.props.shank_length
#             start = end - (self.props.pitch / 2)
#             start_end = start, end
#             bmesh_helpers.interp_vert_mag_along_axis(
#                 bm.verts,
#                 start_end,
#                 self.major_radius,
#             )
#         else:
#             circle = bmesh.ops.create_circle(
#                 bm, radius=self.major_radius, segments=self.props.thread_resolution
#             )
#             top_edges = bmesh_helpers.shared_edges(circle["verts"])
#             bottom_edges = top_edges
#             bmesh.ops.triangle_fill(bm, use_dissolve=True, edges=bottom_edges)
#
#         # Create Shank
#         if self.props.shank_length != 0:
#             top_edges = self._create_shank(top_edges)
#
#         # Create Head
#         if self.props.head_type != "NONE":
#             # Create and merge head mesh
#             head_bm = self._create_head()
#             head_verts, head_faces = bmesh_helpers.merge_bmesh(head_bm, bm)
#
#             # Set head height
#             offset = Vector((0, 0, self.props.length - self.props.tolerance))
#             bmesh.ops.translate(bm, vec=offset, verts=head_verts)
#
#             head_opening = filter(lambda v: v.is_boundary, head_verts)
#             connection_loop = bmesh_helpers.shared_edges(head_opening)
#
#             # Join shank/thread to head
#             open_loops = connection_loop + top_edges
#             bmesh.ops.bridge_loops(bm, edges=open_loops)
#             # bmesh.ops.triangle_fill(bm, edges=open_loops)
#         else:
#             bmesh.ops.triangle_fill(bm, use_dissolve=True, edges=top_edges)
#
#         if self.props.chamfer_length > 0:
#             self._chamfer()
#
#         if self.props.driver_type != "NONE":
#             driver_bm = self._create_driver()
#             bm = boolean_bm(bm, driver_bm, xform=self._driver_xform)
#             driver_bm.free()
#
#         if (
#             self.props.screw_taper_factor > 0
#             and self.props.shank_length != self.props.length
#         ):
#             self._apply_screw_taper()
#
#         if self.props.triangulate:
#             bmesh.ops.triangulate(bm, faces=bm.faces)
#
#         # if self.props.tolerance != 0:
#         #     self._adjust_tolerance()
#
#         if self.props.bisect:
#             self._bisect()
#
#         if self.props.scale != 0.0:
#             self._scale()
#
#         bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
#
#         for f in bm.faces:
#             f.smooth = self.props.shade_smooth
#
#         bm.to_mesh(mesh)
#
#     def _apply_screw_taper(self):
#         taper_length = self.props.length * self.props.screw_taper_factor
#         start_z = taper_length
#         end_z = 0
#         end_radius = 0
#         affected_verts = list(filter(lambda v: v.co.z < start_z, bm.verts))
#         for vert in affected_verts:
#             is_crest = vert[self.vert_layers.thread_crests] == 1
#             # else it's a root vert
#
#             xy, z = vert.co.xy, vert.co.z
#             init_mag = xy.length
#             target_mag = map_range(z, (start_z, end_z), (init_mag, end_radius))
#             new_root_xy = xy.normalized() * target_mag
#
#             if not is_crest:
#                 vert.co.xy = new_root_xy
#             else:
#                 vert.co.xy += new_root_xy - xy
#
#         # Merge by distance to cleanup point
#         bmesh.ops.remove_doubles(bm, verts=affected_verts, dist=0.0001)
#
#     def _mesh_threads(self):
#         """
#         Create mesh threads in bm
#         Returns: Tuple of bottom, top geom dicts whose keys are geometry types
#         """
#
#         def _np2d_to_v3d(coord):
#             """[a,b] np to [b, 0, a] vector"""
#             return Vector((coord[1], 0, coord[0]))
#
#         profile = thread_profiles.ISO_68_1(
#             self.props.pitch,
#             self.props.length,
#             self.props.major_diameter - self.props.tolerance,
#             self.props.starts,
#             self.props.thread_angle,
#             sharp_crest=True,
#             # tolerance=self.props.tolerance,
#         )
#
#         # Create profile verts
#         profile_points = deque(profile.points)
#         first_coord = profile_points.pop()
#         prev_vert = bm.verts.new(_np2d_to_v3d(first_coord))
#         while profile_points:
#             co = _np2d_to_v3d(profile_points.pop())
#             new_vert = bm.verts.new(co)
#             bm.edges.new((prev_vert, new_vert))
#             prev_vert = new_vert
#
#         # Assign vert feature type to layer
#         # List is revered because thread points are processed LIFO
#         # TODO: Move to point initialization like bolt
#         for index, vert in enumerate(reversed(bm.verts[:])):
#             if profile.feature_by_index(index) == "crest":
#                 vert[self.vert_layers.thread_crests] = 1
#             else:
#                 vert[self.vert_layers.thread_roots] = 1
#
#         # Collapse sharp points
#         bmesh.ops.dissolve_degenerate(bm, dist=0.0001)
#
#         start_verts = bm.verts[:]
#         start_profile = start_verts + bm.edges[:]
#         steps = self.props.thread_resolution
#         step_z = self.props.pitch * self.props.starts / steps
#         axis = Vector((0, 0, 1))
#         dvec = Vector((0, 0, step_z))
#         # if self.props.thread_direction == "RIGHT":
#         angle = radians(360)
#         # else:
#         #     angle = radians(-360)
#
#         spun = bmesh.ops.spin(
#             bm,
#             geom=start_profile,
#             angle=angle,
#             steps=steps,
#             dvec=dvec,
#             axis=axis,
#         )
#
#         end_verts = dict_by_type(spun["geom_last"])[BMVert]
#         merge_dist = 0.0001
#         boundary_verts = [
#             vert for vert in chain(start_verts, end_verts) if vert.is_boundary
#         ]
#         bmesh.ops.remove_doubles(bm, verts=boundary_verts, dist=merge_dist)
#
#         # Cut Bottom
#         geom = bmesh_helpers.bm_as_list(bm)
#         loc = Vector((0, 0, self.props.pitch * self.props.starts))
#         norm = Vector((0, 0, -1))
#         merge_dist = 0.01
#         result = bmesh_helpers.trim(
#             bm, geom, dist=merge_dist, loc=loc, norm=norm, cap=True
#         )
#         thread_bottom = dict_by_type(result["geom_cut"])
#
#         # Floor thread mesh
#         min_z = bmesh_helpers.min_vert(bm.verts[:], "z").co.z
#         for v in bm.verts[:]:
#             v.co.z -= min_z
#
#         # Cut Top
#         geom = bmesh_helpers.bm_as_list(bm)
#         loc = Vector((0, 0, self.props.length - self.props.shank_length))
#         norm = Vector((0, 0, 1))
#         result = bmesh_helpers.trim(bm, geom, loc=loc, norm=norm)
#         thread_top = dict_by_type(result["geom_cut"])
#
#         # Tri divide ngons
#         ngons = [f for f in bm.faces if len(f.edges[:]) > 4]
#         bmesh.ops.triangulate(bm, faces=ngons)
#
#         return thread_bottom, thread_top
#
#     @property
#     def _driver_xform(self):
#         boolean_buffer = 0.001
#         z = (self.props.length - self.props.tolerance) + boolean_buffer
#         if self.props.head_type != "NONE":
#             z += self.props.head_length - self.props.tolerance
#         location = Matrix.Translation((0, 0, z))
#         rotation = Matrix.Rotation(radians(180), 4, "X")
#         # scale = Matrix.Scale(self.props.driver_diameter, 4)
#         return location @ rotation
#
#     def _chamfer(self):
#         start_z = self.props.chamfer_length
#         end_z = 0
#         start_radius = self.major_radius
#         end_radius = start_radius - (
#             tan(self.props.chamfer) * self.props.chamfer_length
#         )
#
#         # Add chamfer divisions
#         extra_divisions = self.props.chamfer_divisions
#         if extra_divisions > 0:
#             cut_norm = Vector((0, 0, 1))
#             cut_loc = Vector((0, 0, 0))
#             for cut_z in np.linspace(start_z, end_z, num=extra_divisions):
#                 cut_loc.z = cut_z
#                 geom = bm.faces[:] + bm.edges[:]
#                 bmesh.ops.bisect_plane(
#                     bm, geom=geom, dist=0.0001, plane_co=cut_loc, plane_no=cut_norm
#                 )
#
#         affected_verts = filter(lambda v: v.co.z < start_z, bm.verts)
#         for vert in affected_verts:
#             xy, z = vert.co.xy, vert.co.z
#             init_mag = xy.length
#             target_mag = map_range(z, (start_z, end_z), (init_mag, end_radius))
#             vert.co.xy = xy.normalized() * target_mag
#
#     def _bisect(self) -> None:
#         geom = bmesh_helpers.bm_as_list(bm)
#         duplicate = bmesh.ops.duplicate(bm, geom=geom)
#         front = dict_by_type(duplicate["geom_orig"])
#         back = dict_by_type(duplicate["geom"])
#
#         z_offset = -(self.props.length + self.props.head_length) / 2
#         x_offset = max(self.props.head_diameter, self.props.major_diameter / 2 * 1.1)
#         loc_offset = Vector((x_offset, 0, 0))
#         height_offset = Vector((0, 0, z_offset))
#         bmesh.ops.translate(bm, vec=height_offset, verts=bm.verts)
#
#         front_rot = Euler((radians(90), 0, 0)).to_matrix()
#         cent = Vector.Fill(3, 0)
#         bmesh.ops.rotate(bm, cent=cent, verts=front[BMVert], matrix=front_rot)
#         bmesh.ops.translate(bm, vec=loc_offset, verts=front[BMVert])
#
#         back_rot = Euler((radians(-90), 0, 0)).to_matrix()
#         bmesh.ops.rotate(bm, cent=cent, verts=back[BMVert], matrix=back_rot)
#         bmesh.ops.translate(bm, vec=-loc_offset, verts=back[BMVert])
#
#         geom = bmesh_helpers.bm_as_list(bm)
#         co, no = Vector.Fill(3, 0), Vector((0, 0, -1))
#         trimmed = bmesh.ops.bisect_plane(
#             bm, geom=geom, clear_outer=True, plane_co=co, plane_no=no
#         )
#
#         cut = dict_by_type(trimmed["geom_cut"])
#         edges = bmesh_helpers.shared_edges(cut[BMVert])
#         fills = bmesh.ops.holes_fill(bm, edges=edges)
#         bmesh.ops.triangulate(bm, faces=fills["faces"])
#         bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.00001)
#
#     # @property
#     # def major_radius(self) -> float:
#     #     return self.props.major_diameter / 2 - self.props.tolerance
#
#     # def _create_shank(self, edges: Union[List[BMEdge], None]) -> List[BMEdge]:
#     #     extrusion = bmesh.ops.extrude_edge_only(bm, edges=edges)["geom"]
#     #     extrusion = dict_by_type(extrusion)
#
#     #     for vert in extrusion[BMVert]:
#     #         xy: Vector = vert.co.xy
#     #         mag = xy.length
#     #         # tolerance = xy.normalized() * self.props.tolerance
#     #         new_xy = xy.normalized() * self.major_radius
#     #         offset = xy.normalized() * self.props.runout_offset
#     #         vert.co.xy = new_xy + offset
#
#     #     if self.props.runout_length != 0:
#     #         runout_edges = extrusion[BMEdge]
#     #         runout_verts = extrusion[BMVert]
#     #         extrusion = bmesh.ops.extrude_edge_only(bm, edges=runout_edges)["geom"]
#     #         extrusion = dict_by_type(extrusion)
#     #         for vert in runout_verts:
#     #             vert.co.z += self.props.runout_length
#
#     #     for vert in extrusion[BMVert]:
#     #         vert.co.z += self.props.shank_length - self.props.tolerance
#
#     #     return extrusion[BMEdge]
#
#     def _create_head(self) -> BMesh:
#         # Create head mesh, apply modifiers and remove
#         head: FastenerHead = self.heads[self.props.head_type](self.props)
#         head.apply_transforms()
#         return head.bm
#
#     def _create_driver(self) -> BMesh:
#         driver = self.drivers[self.props.driver_type](self.props)
#         driver.apply_transforms()
#         return driver.bm
#
#
# builders = {subclass.type: subclass for subclass in Fastener.__subclasses__()}
