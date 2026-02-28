// ---- Example 9: Endpoint tangent control ----
//   Specify start and/or end tangent vectors.  Each vector is automatically
//   scaled by the total chord length; a unit vector produces natural
//   arc-length speed.  Magnitude > 1 increases pull, < 1 weakens it.
//   BOSL2 direction constants (UP, RIGHT, etc.) work for 2D curves.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
data = [[0,0], [20,30], [50,25], [80,0]];
// No tangent control (natural):
color("gray") stroke(nurbs_interp_curve(data, 3), width=0.3);
// Tangent: start going straight up, end going straight down:
color("blue") stroke(
    nurbs_interp_curve(data, 3, start_der=[0,1], end_der=[0,-1]),
    width=0.3);
// Tangent: start going right, end going right:
color("red") stroke(
    nurbs_interp_curve(data, 3, start_der=[1,0], end_der=[1,0]),
    width=0.3);
color("black") move_copies(data) circle(r=0.5, $fn=16);