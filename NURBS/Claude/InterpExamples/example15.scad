// ---- Example 15: Low-level surface access ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [
    [[-30,30,0], [0,30,20], [30,30,0]],
    [[-30, 0,10],[0, 0,30], [30, 0,10]],
    [[-30,-30,0],[0,-30,15],[30,-30,0]],
];
result  = nurbs_interp_surface(data, 2);
patch   = result[0];
u_knots = result[1];
v_knots = result[2];
vnf = nurbs_vnf(patch, 2, splinesteps=12,
          knots=[u_knots, v_knots], type="clamped");
vnf_polyhedron(vnf);
color("red")
    for (row = data) for (pt = row)
        translate(pt) sphere(r=1, $fn=16);
