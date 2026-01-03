import bpy
from bpy.types import Mesh
import bmesh
from bmesh.types import BMesh, BMVert, BMEdge
from typing import Union 

def has_non_manifold_vert(mesh: Union[Mesh, BMesh]) -> bool:
    input_is_bm = isinstance(mesh, BMesh)
    if not input_is_bm:
        bm = bmesh.new()
        bm.from_mesh(mesh)
        mesh = bm

    non_manifold_preset = False
    for vert in mesh.verts:
        if not vert.is_manifold:
            non_manifold_preset = True
            break

    if not input_is_bm:
        mesh.free()
    return non_manifold_preset


def is_closed(mesh: Union[Mesh, BMesh]) -> bool:
    input_is_bm = isinstance(mesh, BMesh)
    if not input_is_bm:
        bm = bmesh.new()
        bm.from_mesh(mesh)
        mesh = bm

    is_closed = True
    for edge in mesh.edges:
        if edge.is_boundary:
            is_closed =  False
            break

    if not input_is_bm:
        mesh.free()
    return is_closed