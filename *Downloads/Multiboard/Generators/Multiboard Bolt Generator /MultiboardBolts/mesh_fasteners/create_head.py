from __future__ import annotations
from pathlib import Path
from dataclasses import dataclass, field
from enum import Enum
from functools import partial
from typing import TYPE_CHECKING, Optional

import bmesh
from bmesh.types import BMesh, BMVert, BMEdge, BMFace
from mathutils import Vector, Matrix, Euler

from . import bm_help, bm_filters


def _get_heads_file_mesh(name: str) -> BMesh:
    heads_file = Path(__file__).parent / "meshdata/heads.blend"
    bm = bmesh.new()
    with bm_help.MeshReader(name, heads_file) as mesh_reader:
        bm.from_mesh(mesh_reader)
    return bm


def create_flat(head_length, head_diameter: float, bevel: float, cap_scale_offset: float) -> None:
    bm = _get_heads_file_mesh("FLAT")
    # bmesh.ops.subdivide_edges(self.bm, edges=self.bm.edges[:], smooth=1, cuts=2)
    top_verts, bottom_verts = bm_filters.vert_axis_split(bm.verts)

    # Apply Length
    length_v = Vector((1, 1, head_length))
    bmesh.ops.scale(bm, vec=length_v, verts=top_verts)

    # Apply radius
    # diameter = head_diameter * 2
    # diameter = head_diameter * 2
    base_scaler = Vector((head_diameter, head_diameter, 1))
    bmesh.ops.scale(bm, vec=base_scaler, verts=bottom_verts)

    top_scale_offset = cap_scale_offset
    top_scaler = base_scaler.copy()
    top_scaler.xy *= top_scale_offset
    bmesh.ops.scale(bm, vec=top_scaler, verts=top_verts)

    if bevel > 0:
        geom = bm_help.shared_edges(top_verts)
        bmesh.ops.bevel(
            bm,
            geom=geom,
            offset=bevel,
            segments=4,
            affect="EDGES",
            profile=0.5,
        )
    return bm


def create_hex(head_diameter, head_length, chamfer_scale) -> BMesh:
    bm = _get_heads_file_mesh("HEX")
    top_verts, bottom_verts = bm_filters.vert_axis_split(bm.verts)

    # Apply radius
    diameter = head_diameter
    radius_scaler = Vector((diameter, diameter, 1))
    bmesh.ops.scale(bm, vec=radius_scaler, verts=bm.verts)

    chamfer_verts = []
    for vert in bm.verts:
        is_top_chamfer = vert.co.z > 0.8
        # is_bottom_chamfer = vert.co.z > 0.01 and vert.co.z < 0.22
        # if any((is_top_chamfer, is_bottom_chamfer)):
        if is_top_chamfer:
            chamfer_verts.append(vert)

    # Transform chamfer
    scaler = Vector((1, 1, chamfer_scale))
    bmesh.ops.translate(bm, vec=Vector((0, 0, -1)), verts=top_verts)
    bmesh.ops.scale(bm, vec=scaler, verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector((0, 0, 1)), verts=top_verts)

    # Apply Length
    length_v = Vector((1, 1, head_length))
    bmesh.ops.scale(bm, vec=length_v, verts=top_verts)

    if chamfer_scale <= 0.00001:
        bmesh.ops.dissolve_verts(bm, verts=chamfer_verts)

        # divide ngons
        is_ngon = lambda f: len(f.edges) > 4
        ngons = list(filter(is_ngon, bm.faces))
        bmesh.ops.triangulate(bm, faces=ngons)

    return bm


def create_hex_washer(
        head_diameter,
        head_length,
        chamfer_scale,
        washer_radius,
        washer_length,
) -> BMesh:
    bm = _get_heads_file_mesh("HEX_WASHER")
    # Identify groups
    top_verts, bottom_verts = bm_filters.vert_axis_split(bm.verts)
    washer_top_range = (0.20, 0.30)
    washer_top_verts = list(bm_filters.verts_in_range(bottom_verts, washer_top_range))
    washer_outside_verts = [v for v in bottom_verts if v.co.xy.length > 0.55]

    # Set Total Radius
    radius_scaler = Vector((head_diameter, head_diameter, 1))
    bmesh.ops.scale(bm, vec=radius_scaler, verts=bm.verts)

    chamfer_verts = []
    for vert in bm.verts:
        if vert.co.z > 0.8:
            chamfer_verts.append(vert)

    # Set washer radius
    for v in washer_outside_verts:
        v.co.xy = v.co.xy.normalized()
        v.co.xy *= washer_radius

    # Set washer length
    for v in washer_top_verts:
        v.co.z = washer_length

    # Set chamfer scale
    scale = Vector((1, 1, chamfer_scale))
    origin = Matrix.Translation(Vector((0, 0, -1)))
    bmesh.ops.scale(bm, vec=scale, verts=top_verts, space=origin)

    # Set Total Length
    length_v = Vector((1, 1, head_length))
    bmesh.ops.scale(bm, vec=length_v, verts=top_verts)

    if chamfer_scale <= 0.00001:
        bmesh.ops.dissolve_verts(bm, verts=chamfer_verts)

        # divide ngons
        is_ngon = lambda f: len(f.edges) > 4
        ngons = list(filter(is_ngon, bm.faces))
        bmesh.ops.triangulate(bm, faces=ngons)

    return bm


def create_carriage(
    cap_diameter,
    cap_length,
    nut_diameter,
    nut_length,
) -> BMesh:
    bm = _get_heads_file_mesh("CARRIAGE")
    # Identify groups
    cap_verts, nut_verts = bm_filters.vert_axis_split(bm.verts, split_val=0.55)
    nut_top_verts, _ = bm_filters.vert_axis_split(nut_verts, split_val=0.25)

    # Reset cap verts
    bmesh.ops.translate(bm, vec=Vector((0, 0, -0.5)), verts=cap_verts)

    # Set Nut Length
    offset = Vector((0, 0, -0.5 + nut_length))
    bmesh.ops.translate(bm, vec=offset, verts=cap_verts + nut_top_verts)

    # Set Nut Radius
    diameter = nut_diameter
    radius_scaler = Vector((diameter, diameter, 1))
    bmesh.ops.scale(bm, vec=radius_scaler, verts=nut_verts)

    # Set Cap Radius
    diameter = cap_diameter
    radius_scaler = Vector((diameter, diameter, 1))
    bmesh.ops.scale(bm, vec=radius_scaler, verts=cap_verts)

    # Set Cap Length
    scale = Vector((1, 1, cap_length * 2))
    origin = Matrix.Translation(Vector((0, 0, -nut_length)))
    bmesh.ops.scale(bm, vec=scale, verts=cap_verts, space=origin)
    return bm


def created_socked(head_diameter, head_length, bevel) -> BMesh:
    bm = _get_heads_file_mesh("SOCKED")

    # bmesh.ops.subdivide_edges(self.bm, edges=self.bm.edges[:], smooth=1, cuts=2)
    # Identify groups
    top_verts, bottom_verts = bm_filters.vert_axis_split(bm.verts)

    # Set Total Radius
    radius_scaler = Vector((head_diameter, head_diameter, 1))
    bmesh.ops.scale(bm, vec=radius_scaler, verts=bm.verts)

    # Set Total Length
    length_v = Vector((1, 1, head_length))
    bmesh.ops.scale(bm, vec=length_v, verts=top_verts)

    # Do Set bevel
    if bevel > 0:
        geom = bm_help.shared_edges(top_verts)
        bmesh.ops.bevel(
            bm,
            geom=geom,
            offset=bevel,
            segments=4,
            affect="EDGES",
            profile=0.5,
        )

    return bm


def create_poly_head(
    head_length: float = 1,
    head_diameter: float = 4,
    sides: int = 6,
    crown_chamfer: float = 0.0,
    root_chamfer: float = 0.0,
    chamfer_subdiv: int = 1,
) -> BMesh:
    bm = bmesh.new()
    radius = head_diameter * 0.5
    offset = Matrix.Translation(Vector((0, 0, head_length * 0.5)))
    bmesh.ops.create_cone(
        bm, cap_ends=True, radius1=radius, radius2=radius,
        depth=head_length, segments=sides, matrix=offset
    )
    top_verts = []
    bottom_verts = []
    half_height = head_length * 0.5
    for v in bm.verts:
        if v.co.z > half_height:
            top_verts.append(v)
        else:
            bottom_verts.append(v)
    
    bottom_edges = bm_help.shared_edges(bottom_verts)
    top_edges = bm_help.shared_edges(top_verts)

    if crown_chamfer != 0.0:
        bmesh.ops.bevel(
            bm, geom=top_edges, offset=crown_chamfer, affect="EDGES",
            segments=chamfer_subdiv, profile=0.5
        )
    if root_chamfer != 0.0:
        bmesh.ops.bevel(
            bm, geom=bottom_edges, offset=root_chamfer, affect="EDGES",
            segments=chamfer_subdiv, profile=0.5)

    to_delete = []
    for face in bm.faces:
        if face.normal == Vector((0, 0, -1)):
            to_delete.append(face)

    bmesh.ops.delete(bm, geom=to_delete, context="FACES")

    bottom_edges_attrib = bm.edges.layers.int.new("bottom_edges")
    for e in bm.edges:
        if e.is_boundary:
            e[bottom_edges_attrib] = 1

    return bm