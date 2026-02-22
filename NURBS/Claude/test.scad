// ---- Example 4: Closed polygon ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
 data = [[4.15723, -0.416853], [0.919878, -3.52248], [-4.6257, 0.314422], [0.819475, 3.98495]];
   debug_nurbs_interp(data, 3, type="closed");
