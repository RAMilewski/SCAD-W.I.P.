include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
$fn = 64;
bez = [[10,0], [75,20], [0,50], [25,80]];
debug_bezier(bez, N=len(bez)-1);
path = bezpath_curve(bez, splinesteps = 64, N = len(bez)-1 );
rotate_sweep(path,360);
