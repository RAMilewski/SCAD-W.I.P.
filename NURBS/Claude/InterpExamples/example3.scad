// ---- Example 3: OPEN ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
debug_nurbs_interp(data, 3, type="open");