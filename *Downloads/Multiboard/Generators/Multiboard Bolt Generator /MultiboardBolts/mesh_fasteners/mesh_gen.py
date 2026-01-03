from itertools import chain
from math import pi, radians
from typing import Deque, List, Tuple

import bpy
import bmesh
from bmesh.types import BMVert, BMFace, BMEdge, BMesh
from bpy.types import Mesh
from mathutils import Matrix, Vector, Euler
from .bm_help import bm_as_list


def new_grid_mesh(
    name: str,
    divisions: Tuple[int, int] = (1, 1),
    transform: Matrix = Matrix.Identity(4),
) -> Mesh:
    """
    Create and return a new grid mesh
    """
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bm.loops.layers.uv.new("UV")
    bmesh.ops.create_grid(
        bm,
        x_segments=divisions[0],
        y_segments=divisions[1],
        size=1,
        matrix=transform,
        calc_uvs=True,
    )

    bm.to_mesh(mesh)
    bm.free()
    return mesh


def new_cylinder_mesh(
    radius: float = 1, segements: int = 6, depth: float = 1,
) -> BMesh:
    # mesh = bpy.data.meshes.new("cross")
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=True, segments=segements, radius=radius)

    extrusion = bmesh.ops.extrude_face_region(bm, geom=bm.faces[:])
    translate = Vector((0, 0, depth))
    verts = [i for i in extrusion["geom"] if isinstance(i, BMVert)]
    bmesh.ops.translate(bm, vec=translate, verts=verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return bm


def new_cross_bmesh(
    x_length: float = 4,
    x_width: float = 1,
    y_length: float = 4,
    y_width: float = 1,
    rotation: Euler = Euler((0, 0, 0)),
    depth: float = 1,
    center: bool = True,
) -> BMesh:
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=3, y_segments=3, size=0.5)

    # Group points by their shape influence
    to_delete = []

    is_x_extent = lambda v: abs(v.co.x) > 0.4
    is_y_extent = lambda v: abs(v.co.y) > 0.4

    for vert in bm.verts:
        if vert.co.length > 0.6:
            to_delete.append(vert)
            continue
        if is_x_extent(vert):
            if x_length < y_width or x_width == 0.0:
                to_delete.append(vert)
            else:
                vert.co.x *= x_length
                vert.co.y *= ((x_width * 0.5) / abs(vert.co.y))
        elif is_y_extent(vert):
            if y_length < x_width or y_width == 0.0:
                to_delete.append(vert)
            else:
                vert.co.x *= ((y_width * 0.5) / abs(vert.co.x))
                vert.co.y *= y_length
        else:
            vert.co.x *= (y_width * 0.5) / abs(vert.co.x)
            vert.co.y *= (x_width * 0.5) / abs(vert.co.y)

    # Remove corners 
    bmesh.ops.delete(bm, geom=to_delete)

    if depth != 0:
        extrusion = bmesh.ops.extrude_face_region(bm, geom=bm.faces[:])
        translate = Vector((0, 0, depth))
        verts = [i for i in extrusion["geom"] if isinstance(i, BMVert)]
        bmesh.ops.translate(bm, vec=translate, verts=verts)

    return bm

