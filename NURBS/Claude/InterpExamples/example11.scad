// ---- Example 11: Basic surface interpolation ----
//   A 4x5 grid of 3D data points → smooth interpolating surface.
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [
    [[-50, 50,  0], [-16, 50,  20], [ 16, 50,  10], [50, 50,  0], [80, 50,  5]],
    [[-50, 16, 20], [-16, 16,  40], [ 16, 16,  30], [50, 16, 20], [80, 16, 10]],
    [[-50,-16, 20], [-16,-16,  35], [ 16,-16,  40], [50,-16, 15], [80,-16, 25]],
    [[-50,-50,  0], [-16,-50,  10], [ 16,-50,  20], [50,-50,  0], [80,-50,  5]],
];
debug_nurbs_interp_surface(data, 3, splinesteps=32);