//  ---- Example 4: Closed polygon ----
//  All data points should lie exactly on the boundary of the polygon.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [[0,0], [30,50], [60,40], [80,10], [50,-20], [20,-10]];
path = nurbs_interp_curve(data, 3, splinesteps=16, type="closed");
polygon(path);
color("red") move_copies(data) circle(r=0.25, $fn=16);
//