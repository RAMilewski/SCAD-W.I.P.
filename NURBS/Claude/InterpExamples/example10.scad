//   ---- Example 10: Start tangent only ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [[0,0], [20,30], [50,25], [80,0]];
color("gray") stroke(nurbs_interp_curve(data, 3), width=0.3);
color("blue") stroke(
    nurbs_interp_curve(data, 3, start_der=[0,100]),
    width=0.3);
color("black") move_copies(data) circle(r=0.25, $fn=16);