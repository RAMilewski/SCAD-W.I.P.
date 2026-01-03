from __future__ import annotations
from functools import cached_property
from pathlib import Path
from math import radians, pi
from typing import TYPE_CHECKING, Literal, Optional, Union
from dataclasses import dataclass, field
from csv import DictReader
from typing import Any

import bpy
from bpy.types import Object 
import bmesh
from bmesh.types import BMesh, BMVert, BMEdge, BMFace
from bpy.types import PropertyGroup, Context, Mesh
from mathutils import Vector, Matrix, Euler

from .mesh_fasteners import create_fastener, bm_help, mesh_help
from . import config

if TYPE_CHECKING:
    from . import properties


def get_addon_prefs():
    return bpy.context.preferences.addons[__package__].preferences


@dataclass
class ProfileParams:
    """
    Load profile from csv file, profiles_file by name field
    default file contains:
        big_thread
        mid_thread
        small_thread
    """
    name: Literal["big_thread", "mid_thread", "small_thread"]
    major_diameter: float = field(init=False)
    minor_diameter: float = field(init=False)
    crest_weight: float = field(init=False)
    root_weight: float = field(init=False)
    pitch: float = field(init=False)
    chamfer: float = field(init=False)
    chamfer_length: float = field(init=False)
    profiles_file: Path = config.THREAD_PROFILES_CSV
    prop_overrides: Optional[dict[str, Any]] = None

    def __post_init__(self):
        with open(self.profiles_file, "r") as csv_file:
            reader = DictReader(csv_file)
            try:
                preset = next(line for line in reader if line["name"] == self.name)
            except StopIteration:
                raise ValueError("".join((
                    f"Unable to find thread profile params {self.name}",
                    f"in {self.profiles_file}"
                )))

            self.major_diameter = float(preset["major_diameter"])
            self.minor_diameter = float(preset["minor_diameter"])
            self.crest_weight = float(preset["crest_weight"])
            self.root_weight = float(preset["root_weight"])
            self.pitch = float(preset["pitch"])
            self.chamfer = float(preset["chamfer"])
            self.chamfer_length = float(preset["chamfer_length"])

            if self.prop_overrides:
                for prop, value in self.prop_overrides.items():
                    setattr(self, prop, value)


@dataclass
class ThreadBuilder:
    length: float
    shank_length: float
    tolerance: float
    profile_params: ProfileParams
    mesh: Mesh = field(init=False)
    resolution: int = config.DEFAULT_THREAD_RESOLUTION
    thread_profile: create_fastener.ThreadProfile = field(init=False)
    cap_top: bool = False
    chamfer_top: bool = False

    def __post_init__(self):
        length = self.length - self.shank_length
        self.thread_profile = create_fastener.ThreadProfile(
            pitch = self.profile_params.pitch,
            length = length,
            starts = 1,
            major_diameter = self.profile_params.major_diameter - self.tolerance,
            minor_diameter = self.profile_params.minor_diameter - self.tolerance,
            root_width = self.profile_params.root_weight,
            crest_width = self.profile_params.crest_weight,
            sharp_crest = False,
            profile_type = "CUSTOM",
        )
        self.mesh = self._create_bolt_thread()
    
    def _create_bolt_thread(self) -> Mesh:
        bm = bmesh.new()
        create_fastener.create_bolt_thread(
            bm,
            self.thread_profile,
            divisions = self.resolution,
            reverse_thread = False,
            chamfer = self.profile_params.chamfer,
            chamfer_length = self.profile_params.chamfer_length,
            chamfer_divisions = 0,
            cap_top = False,
            chamfer_top = self.chamfer_top,
            smooth_top_to_minor=True
        )

        if self.shank_length > 0:
            create_fastener.add_shank(
                bm, 
                self.shank_length,
                cap=False,
            )
        else:
            # Hacky fix for bridging and boolean issues
            create_fastener.add_shank(
                bm, 
                0.00001,
                cap=False,
            )
        if self.cap_top:
            to_cap = [edge for edge in bm.edges if edge.is_boundary]
            bmesh.ops.holes_fill(bm, edges=to_cap)

        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        # if self.tolerance != 0.0:
        #     for vert in bm.verts:
        #         if vert.co.z < 0.8:
        #             vert.co += (Vector((0, 0, -1)) * self.tolerance)
        #         elif vert.co.z > self.thread_profile.length  - 0.06:
        #             n = (vert.normal * Vector((1, 1, 0))).normalized()
        #             vert.co += (n * self.tolerance)
        #         else:
        #             vert.co += (vert.normal * self.tolerance)
        #         # vert.co.z -= self.tolerance

        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0001)
        thread_mesh = bpy.data.meshes.new("thread_mesh")
        bm.to_mesh(thread_mesh)
        return thread_mesh


@dataclass
class UncutBolt:
    profile_name: Literal["big_thread", "mid_thread", "small_thread"]
    thread_length: float
    shank_length: float
    tolerance: float
    head_type: Literal["standard_head", "flat_head"] = "standard_head"
    thread_resolution: int = 32
    head_rot_offset: float = 0.0
    # mid_push_fit_mod: bool = False
    mesh: Mesh = field(init=False)
    head_z_start: float = field(init=False)
    head_z_end: float = field(init=False)
    head_length: float = field(init=False)
    total_length: float = field(init=False)
    profile_params: ProfileParams = field(init=False)
    bevel_head_pattern: bool = False,
    is_tbolt: bool = False
    is_folded: bool = False

    def __post_init__(self):
        """ Create uncut bolt mesh """
        # Get head mesh
        self.profile_params = ProfileParams(self.profile_name)

        if self.head_type != "blank":
            head_mesh = self._get_head_mesh().copy()
            self.head_length = sorted([v.co.z for v in head_mesh.vertices])[-1]
            self.head_z_start = self.thread_length
            self.head_z_end = self.head_length + self.head_z_start
            self.total_length = self.head_length + self.thread_length
        else:
            head_mesh = None
            self.head_length = 0.0
            self.head_z_start = 0.00
            self.head_z_end = 0.0
            self.total_length = self.thread_length

        # Create Body
        apply_top_chamfer = self.head_type == "blank" and self.shank_length == 0.0
        thread_mesh = ThreadBuilder(
            self.thread_length,
            self.shank_length,
            self.tolerance,
            self.profile_params,
            resolution=self.thread_resolution,
            cap_top=head_mesh is None,
            chamfer_top=apply_top_chamfer
        ).mesh

        if head_mesh is None:
            self.mesh = thread_mesh
        else:
            # Join head to body
            head_offset = Vector((0, 0, self.thread_length))
            bm = bmesh.new()
            bm.from_mesh(head_mesh)
            if self.bevel_head_pattern:
                self._apply_head_pattern_bevel(bm)

            bmesh.ops.translate(bm, vec=head_offset, verts=bm.verts)
            rot = Matrix.Rotation(self.head_rot_offset, 3, Vector((0, 0, 1)))
            bmesh.ops.rotate(bm, cent=Vector((0, 0, 0)), matrix=rot, verts=bm.verts)
            bm.from_mesh(thread_mesh)
            open_edges = [e for e in bm.edges if e.is_boundary]
            bmesh.ops.bridge_loops(bm, edges=open_edges)

            self.mesh = bpy.data.meshes.new("__uncut_bolt")
            bm.to_mesh(self.mesh)

            # Cleanup
            bm.free()
            bpy.data.meshes.remove(head_mesh)
            bpy.data.meshes.remove(thread_mesh)

        if self.is_tbolt:
            self._apply_tbolt_trims()


    def _apply_tbolt_trims(self):
        bm = bmesh.new()
        bm.from_mesh(self.mesh)

        thread_type = self.profile_params.name
        cut_width = {
            "big_thread": 15,
            "mid_thread": 9, 
            "small_thread": 4.5,
        }[thread_type]

        for sign in (-1, 1):
            loc = Vector((cut_width * 0.5 * sign, 0, 0))
            norm = Vector((1 * sign, 0, 0))
            geom = bm.faces[:] + bm.edges[:] + bm.verts[:]
            bm_help.trim(bm, geom=geom, loc=loc, norm=norm, cap=True)

        bm.to_mesh(self.mesh)
        bm.free()


    def _get_head_mesh(self) -> Mesh:
        if "fit_big" in self.head_type:
            if self.is_tbolt or self.is_folded:
                mesh_name = "multiboard_big_hole_head_tbolt"
            else:
                mesh_name = "multiboard_big_hole_head"
        elif self.head_type == "flat_head_push_fit_mid":
            mesh_name = "multiboard_flat_head_push_fit_mid"
        elif "push_fit_mid" in self.head_type:
            if self.is_tbolt:
                mesh_name = "multiboard_mid_hole_head_tbolt"
                # mesh_name = "multiboard_mid_hole_head"
            else:
                mesh_name = "multiboard_mid_hole_head"
        elif self.head_type.startswith("standard_head"):
            mesh_name = "multiboard_standard_head"
        elif self.head_type.startswith("flat_head"):
            mesh_name = "multiboard_flat_head"
        elif self.head_type.startswith("small_flat_head"):
            mesh_name = "multiboard_small_flat_head"
        elif self.head_type.startswith("small_head"):
            mesh_name = "multiboard_small_head"
        else:
            raise ValueError(f"Unrecognized head type {self.head_type}")

        mesh = _get_resource_mesh(mesh_name)
        if not mesh:
            raise ValueError(f"Couldn't find head type {self.head_type} mesh {mesh_name}")
        return mesh


    def _apply_head_pattern_bevel(self, bm):
        angle_min: float = radians(60)
        bevel_edges = []
        for edge in bm.edges:
            # edge.select_set(False)
            edge: bmesh.types.BMEdge
            face_angle = edge.calc_face_angle_signed(0)
            if face_angle > angle_min:
                bevel_edges.append(edge)

        bmesh.ops.bevel(bm, geom=bevel_edges, offset=0.4, clamp_overlap=True, affect="EDGES")
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.001)


@dataclass
class BoltGenConditionsTable:
    props: properties.BoltProperties

    @cached_property
    def has_full_hole(self):
        return any((
            self.has_full_small_thread_hole,
            self.has_full_mid_push_fit,
        ))

    @cached_property
    def has_head_hole(self):
        test_substrings = (
            "small_thread",
            "push_fit",
        )
        head = self.props.head_type
        return any((s in head for s in test_substrings)) 

    @cached_property
    def has_body_hole(self):
        return self.props.hole_type != "none"


    @cached_property
    def has_full_small_thread_hole(self):
        return all((
            "small_thread" in self.props.head_type or "blank" in self.props.head_type,
            "small_thread" in self.props.hole_type,
        ))

    @cached_property
    def has_full_mid_push_fit(self):
        return all((
            "push_fit_mid" in self.props.head_type,
            "push_fit_hole" in self.props.hole_type,
        ))

    @cached_property
    def requires_bool(self):
        return any((
            self.props.head_type not in {"standard_head", "flat_head"},
            # self.props.is_tbolt,
            self.props.hole_type != "none"
        ))
    

@dataclass
class HoleCutter:
    # bolt_props: properties.BoltProperties
    hole_type: Literal[
        "small_threaded",
        "mid_push_fit",
        "large_push_fit",
    ]
    length: float = 1.0
    resolution: int = 32
    add_printing_mod: bool = False  # For tbolts and folded bolts
    mesh: Mesh = field(init=False)
    z_rot: float = 0
    add_root_union: bool = False
    is_head_cutter: bool = False
    stretch_mid_base: bool = False
    mid_t_correction: bool = False
    is_folded: bool = False

    def __post_init__(self):
        builders = {
            "small_threaded": self._create_small_threaded,
            "mid_push_fit": self._create_mid_push_fit,
            "large_push_fit": self._create_large_push_fit,
        }
        self.mesh = builders[self.hole_type]()

    def remove(self):
        bpy.data.meshes.remove(self.mesh)

    @property
    def _common_thread_attribs(self):
        return {
            "length": self.length,
            "shank_length": 0.0,
            "tolerance": 0.0,
            "cap_top": True,
            "resolution": self.resolution,
        }

    def _create_thread_mesh(self, thread_type: str):
        thread_args = self._common_thread_attribs
        thread_args["profile_params"] = ProfileParams(
            thread_type, prop_overrides={"chamfer": 0.0}
        )
        if self.is_head_cutter:
            thread_args["length"] += 10
        return ThreadBuilder(**thread_args).mesh
    
    def _create_small_threaded(self) -> Mesh:
        mesh = self._create_thread_mesh("small_thread")
        if self.add_printing_mod:
            union_mesh = self._add_union_modifier(mesh, "multiboard_tbolt_small_thread_cutout")
        return mesh

    def add_head_edge_beveller(self, offset: float = -7.0, angle: float = radians(0)):
        cutter = _get_resource_mesh("peak_cutter")
        # loc = Vector((0, 0, self.length + offset))
        # print(angle)
        loc = Matrix.Translation(Vector((0, 0, self.length + offset)))
        rot = Matrix.Rotation(angle, 4, Vector((0, 0, 1)))
        xform = loc @ rot
        mesh_help.boolean_meshes(
            self.mesh,
            cutter,
            operation="UNION",
            output_mesh=self.mesh,
            xform=xform,
        )

    def _create_mid_push_fit(self) -> Mesh:
        # Create mid thread
        mesh = self._create_thread_mesh("mid_thread")
        z_up = Vector((0, 0, 1))

        if self.add_printing_mod:
            mod_mesh = _get_resource_mesh("multiboard_tbolt_push_fit_cutout")
            scale = Matrix.Scale(self.length + 0.01, 4, z_up)
            rot = Matrix.Rotation(self.z_rot, 4, z_up)

            if self.mid_t_correction:
                extra_scale_a = Matrix.Scale(self.length + 0.01, 4, Vector((1, 0, 0 )))
                # extra_scale_b = Matrix.Scale(1.01, 4, Vector((0, 1, 0 )))
                # extra_scale = extra_scale_a @ extra_scale_b
                xform = scale @ extra_scale_a @ rot
            else:
                xform = scale @ rot
            mesh_help.boolean_meshes(
                mesh,
                mod_mesh,
                operation="UNION",
                output_mesh=mesh,
                xform=xform,
            )

        # Add push fit modification, which is a union cylinder
        if self.stretch_mid_base and not self.is_folded:
            union_mesh = _get_resource_mesh("multiboard_mid_push_fit_union_mod_alt").copy()
        else:
            union_mesh = _get_resource_mesh("multiboard_mid_push_fit_union_mod").copy()

        # Transform bottom vert along z for head cutting
        bm = bmesh.new()
        bm.from_mesh(union_mesh)

        # Main transform
        # scale = Matrix.Scale(self.length, 4, z_up)
        # rot = Matrix.Rotation(self.z_rot, 4, z_up)
        # xform = scale @ rot
        # bmesh.ops.transform(bm, matrix=xform, verts=bm.verts)
        rot = Matrix.Rotation(self.z_rot, 4, z_up)
        bmesh.ops.transform(bm, matrix=rot, verts=bm.verts)

        top_verts = []
        bottom_verts = []
        for v in bm.verts:
            if v.co.z > 0.5:
                top_verts.append(v)
            else:
                bottom_verts.append(v)

        bmesh.ops.translate(bm, vec=Vector((0, 0, self.length)), verts=top_verts)

        # Corrects boolean issue
        if not self.stretch_mid_base:
            # Offset to prevent coplanar faces for bool later bool
            bmesh.ops.translate(bm, vec=Vector((0, 0, -0.01)), verts=bottom_verts)

        # elif self.is_folded:
        #     target_vert = next((v for v in bm.verts if v.co.length < 0.001))
        #     target_vert.co.z -= 2.15

        # if self.stretch_mid_base:
        #     # Transform base point
        #     target_vert = next((v for v in bm.verts if v.co.length < 0.001))
        #     target_vert.co.z -= 2.15

        bm.to_mesh(union_mesh)
        bm.free()

        # Union push shape with thread
        z_up = Vector((0, 0, 1))
        scale = Matrix.Scale(self.length, 4, z_up)
        rot = Matrix.Rotation(self.z_rot, 4, z_up)
        xform = scale @ rot
        mesh_help.boolean_meshes(
            mesh,
            union_mesh,
            operation="UNION",
            output_mesh=mesh,
            # xform=xform,
        )
        bpy.data.meshes.remove(union_mesh)

        return mesh

    def _create_large_push_fit(self) -> Mesh:
        mesh = self._create_thread_mesh("big_thread")
        # if self.add_thread_mod:
        #     union_mesh = self._add_union_modifier(mesh, "multiboard_tbolt_small_thread_cutout")

        return mesh

    def _add_union_modifier(self, mesh, union_mesh_name: str):
        union_mesh = _get_resource_mesh(union_mesh_name)
        loc = Matrix.Translation(Vector((0, 0, 0.001)))
        scale = Matrix.Scale(self.length, 4, Vector((0, 0, 1)))
        mesh_help.boolean_meshes(
            mesh,
            union_mesh,
            output_mesh=mesh,
            operation="UNION",
            xform=loc @ scale,
        )
        bpy.data.meshes.remove(union_mesh)


def update_bolt(props: properties.BoltProperties, context: Context):
    if props.pause_prop_update:
        return None

    props.pause_prop_update = True
    if props.shank_length > props.thread_lengh:
        props.shank_length = min(props.shank_length, props.thread_lengh) - (props.thread_lengh * 0.1)
    props.pause_prop_update = False

    bolt_mesh: Mesh = props.id_data.data
    cache_name = f"__bolt_cached_{bolt_mesh.as_pointer()}"
    condition_table = BoltGenConditionsTable(props)

    bolt_mesh.clear_geometry()

    head_rot_offset = radians(22.5) if props.is_tbolt else 0.0
    uncut_bolt = UncutBolt(
        props.thread_type,
        props.thread_lengh,
        props.shank_length,
        props.tolerance,
        props.head_type,
        props.thread_resolution,
        head_rot_offset=head_rot_offset,
        # mid_push_fit_mod=condition_table.has_full_mid_push_fit,
        is_tbolt=props.is_tbolt,
        is_folded=props.is_folded,
        bevel_head_pattern=props.is_folded,
    )

    bm = bmesh.new()
    bm.from_mesh(uncut_bolt.mesh)
    bm.to_mesh(bolt_mesh)
    bm.free()
    bpy.data.meshes.remove(uncut_bolt.mesh)

    # Handle full through hole conditions
    if condition_table.has_full_hole:
        if condition_table.has_full_small_thread_hole:
            hole_type = "small_threaded"
        elif condition_table.has_full_mid_push_fit:
            hole_type = "mid_push_fit"
        else:
            raise ValueError("Unrecognized full hole conditions")

        length = uncut_bolt.thread_length + uncut_bolt.head_length + 2
        hole_cutter = HoleCutter(
            hole_type,
            length,
            props.thread_resolution,
            add_printing_mod=props.is_tbolt or props.is_folded,
        )

        if "push_fit_mid" in props.head_type:
            beveller_loc = -9.0
            # if props.is
            # angle = 0.0
            hole_cutter.add_head_edge_beveller(beveller_loc)

        bool_z_offset = -0.1
        mesh_help.boolean_meshes(
            bolt_mesh,
            hole_cutter.mesh,
            output_mesh=bolt_mesh,
            # operation="UNION",
            xform=Vector((0, 0, bool_z_offset))
        )
        mesh_help.delete_non_manifold_faces(bolt_mesh)

        hole_cutter.remove()
    else:
        # Handle Head holes
        if condition_table.has_head_hole:
            extra_offset = 0.0
            beveller_loc = 0.0
            stetch_mid_base = False
            mid_t_corretion = False
            if "small_thread" in props.head_type:
                cutter_name = "small_threaded"
                if props.thread_type == "small_thread":
                    extra_offset = 1.5
            elif "push_fit_mid" in props.head_type:
                cutter_name = "mid_push_fit"
                extra_offset = 1.0
                beveller_loc = -8
                # if "flat" in props.head_type:
                #     beveller_loc += 6.2
                if props.is_bolt and not props.is_folded:
                    mid_t_corretion = True
                if not props.is_tbolt:
                    stetch_mid_base = True
                # if "flat" in props.head_type:
                #     pass
            elif "push_fit_big" in props.head_type:
                cutter_name = "large_push_fit"
                extra_offset = 4

            cutter_length = uncut_bolt.head_length + 0.01
            if props.head_type == "flat_head_push_fit_mid":
                cutter_length += 6.2

            length_offset = 0.0
            hole_cutter = HoleCutter(
                cutter_name,
                cutter_length + length_offset,
                props.thread_resolution,
                add_printing_mod=props.is_tbolt or props.is_folded,
                is_head_cutter=True,
                stretch_mid_base=stetch_mid_base,
                mid_t_correction=mid_t_corretion,
                is_folded=props.is_folded,
            )

            if "push_fit_mid" in props.head_type:
                if props.is_tbolt or props.is_folded:
                    angle = 0.0
                else:
                    angle = radians(22.5)
                hole_cutter.add_head_edge_beveller(beveller_loc, angle)


            z_loc = uncut_bolt.thread_length + extra_offset
            if props.head_type == "flat_head_push_fit_mid":
                z_loc -= 6.2
            loc = Matrix.Translation(Vector((0, 0, z_loc)))

            # hacky shit
            if all((
                "push_fit_mid" in props.head_type,
                not props.is_tbolt,
                not props.is_folded,
            )):
                xform = loc @ Matrix.Rotation(radians(22.5), 4, Vector((0, 0, 1)))
            else:
                xform = loc

            # "push_fit_mid" in props.head_type,

            mesh_help.boolean_meshes(bolt_mesh, hole_cutter.mesh, output_mesh=bolt_mesh, xform=xform)
            # mesh_help.boolean_meshes(bolt_mesh, hole_cutter.mesh, output_mesh=bolt_mesh, xform=offset, operation="UNION")
            # debug_obj = mesh_help.quick_mesh_add(hole_cutter.mesh)
            # debug_obj.location.x += 10
            # hole_cutter.remove()
            # mesh_help.delete_non_manifold_faces(bolt_mesh)
            # return None

        # Handle thread holes
        if condition_table.has_body_hole:
            cutter_length = uncut_bolt.thread_length
            length_offset = 0.0
            extra_offset = 0.0
            if "push_fit" in props.head_type:
                length_offset = 2.0

            if props.hole_type == "small_thread_hole":
                cutter_name = "small_threaded"
            elif props.hole_type == "push_fit_hole":
                cutter_name = "mid_push_fit"
            hole_cutter = HoleCutter(
                cutter_name,
                cutter_length + 0.02 + length_offset,
                props.thread_resolution,
                add_printing_mod=props.is_tbolt or props.is_folded,
            )
            offset = Vector((0, 0, -0.01 + extra_offset))
            mesh_help.boolean_meshes(bolt_mesh, hole_cutter.mesh, output_mesh=bolt_mesh, xform=offset)

            hole_cutter.remove()
            # mesh_help.delete_non_manifold_faces(bolt_mesh)

            # # Create intersection shape
            # intersection_shape_radius = 7.25
            # intersector_bm = bmesh.new()
            # m = Matrix.Rotation(radians(22.5), 4, Vector((0, 0, 1)))
            # bmesh.ops.create_circle(intersector_bm, radius=intersection_shape_radius, segments=8, cap_ends=True, matrix=m)
            # bmesh.ops.translate(intersector_bm, vec=Vector((0, 0, -2)), verts=intersector_bm.verts)
            # extrusion = bmesh.ops.extrude_face_region(intersector_bm, geom=intersector_bm.faces)["geom"]
            # extruded_verts = bm_help.dict_by_type(extrusion)[BMVert]
            # bmesh.ops.translate(intersector_bm, vec=Vector((0, 0, cutter_length + 2)), verts=extruded_verts)
            # intersection_mesh = bpy.data.meshes.new('intersector')
            # intersector_bm.to_mesh(intersection_mesh)

            # # Apply Intersection
            # mesh_help.boolean_meshes(hole_cutter.mesh, intersection_mesh, output_mesh=hole_cutter.mesh, operation="UNION")
            # bpy.data.meshes.remove(intersection_mesh)

            # # Boolean again main bolt
            # offset = Vector((0, 0, -1))
            # mesh_help.boolean_meshes(bolt_mesh, hole_cutter.mesh, output_mesh=bolt_mesh, xform=offset)
            # bpy.data.meshes.remove(hole_cutter.mesh)

        # if props.is_tbolt:
        #     # create_fastener.trim_by_fac(bn, trim_fac)
        #     tcutter_mesh = bpy.data.meshes.new("t_cutter")
        #     cutter_bm = bmesh.new()
        #     bmesh.ops.create_cube(cutter_bm, size=1)
        #     cutter_z_size = 10 + props.thread_lengh * 2
        #     cutter_sizes = {
        #         "big_thread": Vector((15, 50, cutter_z_size)),
        #         "mid_thread": Vector((9, 40, cutter_z_size)),
        #         "small_thread": Vector((4.5, 25, cutter_z_size)),
        #     }
        #     scaler = cutter_sizes[props.thread_type]
        #     bmesh.ops.scale(cutter_bm, vec=scaler, verts=cutter_bm.verts)
        #     offset = Vector((0, 0, uncut_bolt.total_length * 0.5))
        #     bmesh.ops.translate(cutter_bm, vec=offset, verts=cutter_bm.verts)

        #     cutter_bm.to_mesh(tcutter_mesh)
        #     cutter_bm.free()

        #     mesh_help.boolean_meshes(bolt_mesh, tcutter_mesh, operation="INTERSECT", output_mesh=bolt_mesh)
        #     bpy.data.meshes.remove(tcutter_mesh)

    if props.is_folded:
        joiner_mesh_name = _identify_required_joiner(props)
        joiner_mesh = _get_resource_mesh(joiner_mesh_name)
        _convert_to_folded(bolt_mesh, joiner_mesh, spacing=0.2)

    # Shade smooth
    _set_faces_smooth_shade(bolt_mesh, props.smooth_shade)

    bolt_object: Object = props.id_data
    context.view_layer.objects.active = bolt_object
    bolt_object.select_set(True)
    context.view_layer.update()
    _apply_smooth_shade(bolt_object, props.smooth_shade)

    # Dirty mesh cleanup
    bm = bmesh.new()
    bm.from_mesh(bolt_mesh)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.001)
    non_manifold_edges = [e for e in bm.edges if not e.is_manifold]
    if len(non_manifold_edges) == 3:
        bmesh.ops.holes_fill(bm, edges=non_manifold_edges, sides=3)

    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.001)
    bm.to_mesh(bolt_mesh)
    bm.free()


def _apply_smooth_shade(object: Object, value: bool):
    is_bpy_ver_over_4_1 = bpy.app.version[0] >=4 and bpy.app.version[1] > 0
    if is_bpy_ver_over_4_1:
        if value:
            bpy.ops.object.shade_smooth_by_angle(angle=radians(15))
        else:
            bpy.ops.object.shade_smooth_by_angle(angle=radians(0))
    else:
        # if props.smooth_shade:
        #     bpy.ops.object.shade_smooth(keep_sharp_edges=False)
        object.data.use_auto_smooth = value
        object.data.auto_smooth_angle = radians(16)


def _identify_required_joiner(props: properties.BoltProperties) -> str:
    is_small_head = any((
            "small_head" in props.head_type,
            "small_flat_head" in props.head_type,
        ))
    is_small_thread_head = "small_thread" in props.head_type

    if props.head_type in {"standard_head", "flat_head"}:
        joiner_mesh_name = "multiboard_folded_standard_joiner"
    elif props.head_type in {"standard_head_small_thread", "flat_head_small_thread"}:
        joiner_mesh_name = "multiboard_folded_small_hole_joiner"
    elif props.head_type == "standard_head_push_fit_big":
        joiner_mesh_name = "multiboard_folded_big_hole_joiner"
    elif props.head_type in {"standard_head_push_fit_mid", "flat_head_push_fit_mid"}:
        joiner_mesh_name = "multiboard_folded_mid_hole_joiner"
    elif is_small_head and not is_small_thread_head:
        joiner_mesh_name = "multiboard_folded_small_head_joiner"
    elif is_small_head and is_small_thread_head:
        joiner_mesh_name = "multiboard_folded_small_head_small_thread_joiner"
    elif props.head_type == "blank":
        if props.thread_type == "big_thread":
            if props.hole_type == "small_thread_hole":
                joiner_mesh_name = "multiboard_folded_rod_big_small_thread_joiner"
            elif props.hole_type == "push_fit_hole":
                joiner_mesh_name = "multiboard_folded_rod_big_push_fit_mid_joiner"
            else:
                joiner_mesh_name = "multiboard_folded_thread_joiner_big"
        elif props.thread_type == "mid_thread":
            if props.hole_type == "small_thread_hole":
                joiner_mesh_name = "multiboard_folded_rod_mid_small_thread_joiner"
            else:
                joiner_mesh_name = "multiboard_folded_thread_joiner_mid"
        elif props.thread_type == "small_thread":
            joiner_mesh_name = "multiboard_folded_thread_joiner_small"
    else:
        raise ValueError(f"Unrecognized folding generation conditions {(props.head_type, props.thread_type)}")
    return joiner_mesh_name


def _set_faces_smooth_shade(mesh: Union[BMesh, Mesh], value: bool):
    if isinstance(mesh, Mesh):
        bm = bmesh.new()
        bm.from_mesh(mesh)
        for f in bm.faces:
            f.smooth = value
        bm.to_mesh(mesh)
        bm.free()
    else:
        for f in mesh.faces:
            f.smooth = value


def _get_resource_mesh(mesh_name):
    """
    Get mesh from resource file, appending if necessary
    WARNING: Do not edit the mesh in place
    """
    thread_extension_mesh = bpy.data.meshes.get(mesh_name)
    if thread_extension_mesh:
        return thread_extension_mesh
    else:
        with bpy.data.libraries.load(str(config.MESH_LIBRARY), link=False) as (data_from, data_to):
            data_to.meshes = [mesh_name]
    return bpy.data.meshes.get(mesh_name)


# def _get_tbolt_thread_cutter_mesh(
#         bolt_props: properties.BoltProperties,
#     ) -> Mesh:
#     cutter_mesh_name = "multiboard_tbolt_small_thread_cutout"
#     cutter_mesh = _get_resource_mesh(cutter_mesh_name).copy()
#     return cutter_mesh


# def _add_tbolt_small_thread_modification(
#         cutter_length: float,
#         thread_mesh: Mesh,
#         z_offset = -0.01
# ):
#     cutter_mesh_name = "multiboard_tbolt_small_thread_cutout"
#     thread_extension_mesh = _get_resource_mesh(cutter_mesh_name)

#     loc = Matrix.Translation(Vector((0, 0, z_offset)))
#     scale = Matrix.Scale(cutter_length, 4, Vector((0, 0, 1)))
#     mesh_help.boolean_meshes(
#         thread_mesh,
#         thread_extension_mesh,
#         output_mesh=thread_mesh,
#         operation="UNION",
#         xform=loc @ scale,
#     )


def _convert_to_folded(
    mesh: Union[bpy.types.Mesh, bmesh.types.BMesh],
    joiner_mesh: Mesh,
    spacing: float = 10.0,
) -> bpy.types.Mesh:
    """
    Split mesh into two section for the purposes of 3d printing
    """
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.001)

    max_z = sorted([v.co.z for v in bm.verts])[-1]
    rot = Matrix.Rotation(radians(180), 4, Vector((0, 1, 0)))
    loc = Matrix.Translation(Vector((0, 0, max_z)))
    bmesh.ops.transform(bm, matrix=loc @ rot, verts=bm.verts)

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

    bm.from_mesh(joiner_mesh)
    bm.to_mesh(mesh)
    bm.free()

    # xform = Matrix.Translation(Vector((0, 0, 0.011)))
    # mesh_help.boolean_meshes(
    #     mesh,
    #     joiner_mesh,
    #     operation="UNION",
    #     output_mesh=mesh,
    #     xform=xform,
    # )
