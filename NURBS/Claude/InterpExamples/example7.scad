// ---- Example 7: 3D closed curve ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data3d = [[20,0,0],[0,20,10],[-20,0,20],[0,-20,10]];
path = nurbs_interp_curve(data3d, 3, splinesteps=32, type="closed");
stroke(path, width=1);
color("red") move_copies(data3d) sphere(r=1.5, $fn=16);