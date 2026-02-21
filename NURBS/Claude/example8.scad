// ---- Example 8: Centripetal parameterization ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
sharp = [[0,0], [5,40], [10,0], [50,0], [55,40], [60,0]];
color("blue")  stroke(nurbs_interp_curve(sharp, 3), width=0.5);
color("red")   stroke(nurbs_interp_curve(sharp, 3, centripetal=true), width=0.5);
color("green") move_copies(sharp) circle(r=1, $fn=16);
