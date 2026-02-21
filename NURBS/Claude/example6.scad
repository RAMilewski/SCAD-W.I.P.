// ---- Example 6: Low-level access ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
result  = nurbs_interp(data, 3, type="clamped", centripetal = true);
control = result[0];
knots   = result[1];
curve = nurbs_curve(control, 3, splinesteps=24, knots=knots, type="clamped");
stroke(curve, width = 0.5);