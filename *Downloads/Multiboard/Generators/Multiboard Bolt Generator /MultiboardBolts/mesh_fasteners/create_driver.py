from __future__ import annotations
from dataclasses import dataclass
from typing import TYPE_CHECKING

import bmesh
from mathutils import Vector, Euler
from bmesh.types import BMesh, BMVert, BMEdge, BMFace

from . import bm_filters, bm_help, mesh_gen, create_fastener


def create_cross(
    depth,
    x_length,
    x_width,
    y_length,
    y_width,
    taper_amnt,
) -> BMesh:
    bm = mesh_gen.new_cross_bmesh(x_length, x_width, y_length, y_width, depth=depth, center=False)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0001)
    bmesh.ops.dissolve_degenerate(bm, edges=bm.edges, dist=0.0001)
    top_verts, bottom_verts = bm_filters.vert_axis_split(bm.verts)
    taper = Vector((taper_amnt, taper_amnt, 1))
    bmesh.ops.scale(bm, vec=taper, verts=bottom_verts)
    return bm


def create_polygon(
    depth,
    radius,
    taper,
    sides,
) -> BMesh:
    bm = mesh_gen.new_cylinder_mesh(radius, sides, depth)
    top_verts, bottom_verts = bm_filters.vert_axis_split(bm.verts, 0.0001)
    taper_amnt = taper
    taper = Vector((taper_amnt, taper_amnt, 1))
    bmesh.ops.scale(bm, vec=taper, verts=bottom_verts)
    return bm


def create_slotted(
    depth,
    x_length,
    x_width,
    taper_amnt,
) -> BMesh:
    # bm = mesh_gen.new_cross_bmesh(x_length, x_width, 0, 0, depth=depth, center=False)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.translate(bm, vec=(0, 0, 0.5), verts=bm.verts)

    scaler = Vector((x_width, x_length, depth))
    bmesh.ops.scale(bm, vec=scaler, verts=bm.verts)

    top_verts, _ = bm_filters.vert_axis_split(bm.verts, 0.0001)
    taper_verts = [v for v in bm.verts if v.co.z < depth * 0.5]
    taper = Vector((taper_amnt, taper_amnt, 1))
    bmesh.ops.scale(bm, vec=taper, verts=taper_verts)
    return bm


def created_threaded(
    profile: create_fastener.ThreadProfile,
    push_fit_fac: float = 0.0,
    push_fit_sides: int = 8,
    push_fit_base_offset: float = 0.0,
    reverse_thread: bool = False,
) -> BMesh:
    """
    Create a threaded driver with optional push fit modification.
    Push fit modification is the unioning of the threaded driver with a low resolution cyclingdrical container
    push_fit: push fit cylinder radius as an offset from the thread profiles minor radius
    push_fit_sides: Resolution of push fit cylinder
    push_fit_base_offset: Cylinder has fan base, this controls centrepoint's offset
    """
    # TODO: missing some params and needs nicer top termination
    bm = bmesh.new()
    create_fastener.create_thread(
        bm,
        profile,
        cap_top=True,
        cap_bottom=True,
        smooth_top_termination=True,
        smooth_bottom_termination=False,
        terminate_outward=True,
        reverse_thread=reverse_thread
    )

    interp_length = profile.length * 0.2
    start_end = (profile.length - interp_length, profile.length)
    target_mat = profile.major_radius * 1.05
    bm_help.interp_vert_mag_along_axis(bm.verts, start_end, target_mat)

    top_face_attrib = bm.faces.layers.int.get("top_face")
    top_faces = [face for face in bm.faces if face[top_face_attrib] == 1]
    top_extrusion = bmesh.ops.extrude_face_region(bm, geom=top_faces)["geom"]
    bmesh.ops.delete(bm, geom=top_faces, context="FACES")
    extruded_verts = bm_help.dict_by_type(top_extrusion)[BMVert]
    offset = Vector((0, 0, profile.length + 4))
    bmesh.ops.translate(bm, vec=offset, verts=extruded_verts)

    if push_fit_fac > 0.0:
        push_fit_bm = bmesh.new()
        bmesh.ops.create_circle(
            push_fit_bm,
            cap_ends=True,
            cap_tris=True,
            radius=profile.minor_radius + (profile.minor_radius * push_fit_fac),
            segments=push_fit_sides,
        )
        extrusion = bmesh.ops.extrude_face_region(push_fit_bm, geom=push_fit_bm.faces)['geom']
        extruded_verts = bm_help.dict_by_type(extrusion)[BMVert]
        bmesh.ops.translate(push_fit_bm, vec=(0, 0, profile.length * 1.2), verts=extruded_verts)

        # Apply bottom offset
        center_top_vert = next((v for v in extruded_verts if v.co.x < 0.001))
        center_bottom_vert = next((v for v in push_fit_bm.verts if v.co.x < 0.001))
        center_bottom_vert.co.z = -push_fit_base_offset
        center_top_vert.co.z = push_fit_base_offset
        bm_help.boolean_bm(bm, push_fit_bm, operation="UNION")

    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0001)
    return bm