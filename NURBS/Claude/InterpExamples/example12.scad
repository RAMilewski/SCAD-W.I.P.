// ---- Example 12: Different degrees per direction ----
//   Quadratic in u, cubic in v.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [
    for (u = [-40:20:40])
        [for (v = [-40:20:40])
            [v, u, 15*sin(u*3)*cos(v*3)]]
];
vnf = nurbs_interp_vnf(data, [2,3], splinesteps=8);
vnf_polyhedron(vnf);