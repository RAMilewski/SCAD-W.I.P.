from typing import Literal, Union, Optional, Iterable
from itertools import repeat
import bpy
from bpy.types import Object, Mesh, Modifier
from bmesh.types import BMVert
from mathutils import Matrix, Vector
import bmesh

BoolOperation = Literal["UNION", "INTERSECT", "DIFFERENCE"]

def clean_non_manifold(bm):
    pass

def boolean_meshes(
    target: Mesh,
    bool_mesh: Mesh,
    operation: BoolOperation = "DIFFERENCE",
    xform: Union[Matrix, Vector] = Matrix.Identity(4),
    solver: str = "EXACT",
    output_mesh: Optional[Mesh] = None,
) -> Mesh:
    if isinstance(xform, Vector):
        xform = Matrix.Translation(xform)
    
    if not output_mesh:
        output_mesh = target
    
    bool_obj_a: Object = bpy.data.objects.new("__TEMP_BOOL_A", object_data=target)
    bool_obj_b: Object = bpy.data.objects.new("__TEMP_BOOL_B", object_data=bool_mesh)
    bpy.context.scene.collection.objects.link(bool_obj_a)
    bpy.context.scene.collection.objects.link(bool_obj_b)

    # Transform object b
    bool_obj_b.matrix_world = xform

    modifier = bool_obj_a.modifiers.new(name="temp_bool", type="BOOLEAN")
    modifier.solver = solver
    modifier.object = bool_obj_b
    modifier.operation = operation

    # Apply boolean result
    # ctx = bpy.context.copy()
    # ctx["active_object"] = bool_obj_a
    # bpy.context.view_layer.update()
    # with bpy.context.temp_override(**{"active_object": bool_obj_a}):
    #     bpy.ops.object.modifier_apply(modifier=modifier.name)

    dg = bpy.context.evaluated_depsgraph_get()
    evaled = bool_obj_a.evaluated_get(dg)
    bm = bmesh.new()
    bm.from_mesh(evaled.data)
    bm.to_mesh(output_mesh)
    bm.free()
    # mesh_result = evaled.data.copy()
    # target.clear()
    # target.from_mesh(mesh_result)

    # Cleanup
    bpy.data.objects.remove(bool_obj_a)
    bpy.data.objects.remove(bool_obj_b)

    return target

def boolean_mesh_stack(
    target: Mesh,
    bool_meshes: Iterable[Mesh],
    operations: Iterable[BoolOperation] = "DIFFERENCE",
    xforms: Optional[Iterable[Matrix]] = Matrix.Identity(4),
    solvers: Optional[Iterable[str]] = "EXACT",
    output_mesh: Optional[Mesh] = None,
) -> Mesh:
    if isinstance(xform, Vector):
        xform = Matrix.Translation(xform)
    
    if not output_mesh:
        output_mesh = target

    # When no value or non-iterable provided, create a repeater of the value
    if isinstance(xforms, Matrix):
        xforms = repeat(xforms)
    if solvers in {"EXACT", "FAST"}:
        solvers = repeat(solvers)
    if operations in {"UNION", "INTERSECT", "DIFFERENCE"}:
        operations = repeat(operations)

    target_obj = bpy.data.objects.new("__bool_target", object_data=target)

    temp_bool_objects = [target_obj,]
    for mesh, operation, xform, solver in zip(bool_meshes, operations, xforms, solvers):

        # Create scene copy of object
        bool_obj = bpy.data.objects.new("__tempbool", object_data=mesh)
        temp_bool_objects.append(bool_obj)
        bool_obj.matrix_world = xform

        # Setup bool modifier
        modifier = target_obj.modifiers.new(name="bool", type="BOOLEAN")
        modifier.solver = solver
        modifier.object = bool_obj
        modifier.operation = operation

    # Apply boolean result
    # ctx = bpy.context.copy()
    # ctx["active_object"] = bool_obj_a
    # bpy.context.view_layer.update()
    # with bpy.context.temp_override(**{"active_object": bool_obj_a}):
    #     bpy.ops.object.modifier_apply(modifier=modifier.name)

    dg = bpy.context.evaluated_depsgraph_get()
    evaled = target_obj.evaluated_get(dg)

    bm = bmesh.new()
    bm.from_mesh(evaled.data)
    bm.to_mesh(output_mesh)
    bm.free()

    # Cleanup
    for obj in temp_bool_objects:
        bpy.data.objects.remove(obj)

    return target



def calc_mesh_bbox(mesh: Mesh) -> tuple[Vector, Vector]:
    bm = bmesh.new()
    bm.from_mesh(mesh)
    verts = iter(bm.verts)
    first_vert = next(verts)

    min_corner = first_vert.co.copy()
    max_corner = min_corner.copy()
    for vert in verts:
        min_corner.x = min(vert.co.x, min_corner.x)
        min_corner.y = min(vert.co.y, min_corner.y)
        min_corner.z = min(vert.co.z, min_corner.z)

        max_corner.x = max(vert.co.x, max_corner.x)
        max_corner.y = max(vert.co.y, max_corner.y)
        max_corner.z = max(vert.co.z, max_corner.z)

    bm.free()
    return min_corner, max_corner


def delete_non_manifold_faces(mesh: Mesh):
    bm = bmesh.new()
    bm.from_mesh(mesh)

    non_manifold_faces = list()
    for face in bm.faces:
        has_manifold_vert = any(v.is_manifold for v in face.verts)
        if not has_manifold_vert:
            non_manifold_faces.append(face)

    bmesh.ops.delete(bm, geom=non_manifold_faces, context="FACES")
    bm.to_mesh(mesh)
    bm.free()

def quick_mesh_add(mesh: Mesh, name: str ="quick_add") -> bpy.types.Object:
    obj = bpy.data.objects.new(name, object_data=mesh)
    bpy.context.collection.objects.link(obj)
    return obj