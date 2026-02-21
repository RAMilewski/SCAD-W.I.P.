// ---- Example 2: CLOSED ----
// Do NOT repeat the first point at the end.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [[0,0], [30,50], [60,40], [80,10], [50,-20], [20,-10]];
debug_nurbs_interp(data, 3, type="closed", splinesteps = 64);
//