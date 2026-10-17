include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

$fn = 72;

side = [[5, 0, 0], [4.928, 0, 2.155], [6.788, 0, 4.804], [5.095, 0, 7.344]];

//stroke(side, width = .2);

path = nurbs_curve(nurbs_interp(side,3), splinesteps = 32);

echo(path);

rotate_sweep(path_sweep(circle(0.25), path), 360);