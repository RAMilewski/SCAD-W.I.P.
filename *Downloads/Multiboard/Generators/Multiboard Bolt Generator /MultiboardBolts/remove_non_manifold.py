import bpy
import bmesh
from bmesh.types import BMesh, BMEdge, BMVert

def clean_non_manifold(bm: bmesh.types.BMesh):
    non_manifold_verts = [v for v in bm.verts if not v.is_manifold]
    non_manifold_edges = [e for e in bm.edges if not e.is_manifold]
    # non_manifold_edges = [e for e in bm.edges if not e.is_manifold]
    # self.delete_loose()
    # self.delete_interior()
    # self.remove_doubles(self.threshold)
    # self.dissolve_degenerate(self.threshold)
    # self.fix_non_manifold(context, self.sides)  # may take a while
    # self.make_normals_consistently_outwards()

    for e in bm.edges:
        # if not e.is_manifold]
        if e.calc_length() < 0.001:
            print(e)


mesh = bpy.context.active_object.data
bm = bmesh.new()
bm.from_mesh(mesh)
clean_non_manifold(bm)
bm.to_mesh(mesh)
bm.free()