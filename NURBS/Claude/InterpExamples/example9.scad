// ---- Example 9: Endpoint tangent control ----
//   Specify start and/or end tangent vectors.  The tangent vector
//   controls both direction and magnitude — a longer vector makes
//   the curve "pull" more strongly in that direction.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [[0,0], [20,30], [50,25], [80,0]];
// No tangent control (natural):
color("gray") stroke(nurbs_interp_curve(data, 3), width=0.3);
// Tangent: start going straight up, end going straight down:
color("blue") stroke(
    nurbs_interp_curve(data, 3, start_der=[0,80], end_der=[0,-80]),
    width=0.3);
// Tangent: start going right, end going right:
color("red") stroke(
    nurbs_interp_curve(data, 3, start_der=[80,0], end_der=[80,0]),
    width=0.3);
color("black") move_copies(data) circle(r=0.25, $fn=16);