// ---- Example 5: Get just the path ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>v
include <nurbs_interp.scad>
//
data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
path = nurbs_interp_curve(data, 3, splinesteps=32, type="clamped");
stroke(path, width=0.5);
color("red") move_copies(data) circle(r=1.5, $fn=16);