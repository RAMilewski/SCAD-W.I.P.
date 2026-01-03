from math import radians
import bpy
import bmesh
from mathutils import Vector
from typing import Union

def bevel_edge_by_signed_face_angle(target: bpy.types.Mesh, angle_min: float = radians(60)):
    bm = bmesh.new()
    bm.from_mesh(target)

    bevel_edges = []
    for edge in bm.edges:
        # edge.select_set(False)
        edge: bmesh.types.BMEdge
        face_angle = edge.calc_face_angle_signed(0)
        if face_angle > angle_min:
            bevel_edges.append(edge)

    bmesh.ops.bevel(bm, geom=bevel_edges, offset=0.4, clamp_overlap=True, affect="EDGES")
    bm.to_mesh(target)
    bm.free()