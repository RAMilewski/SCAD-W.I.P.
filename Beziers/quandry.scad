include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
$fn = 64;
bez = [[10,0], [25,45], [5,70], [12,100]];
cpath = bezpath_close_to_axis(bez, axis = "Y");
path = bezpath_curve(cpath, splinesteps = 64, N = len(bez)-1 );

rotate_sweep(path,360, texture = "wave_ribs", tex_depth = 3, closed = true);

right(50)

rotate_sweep(path,360, texture = "wave_ribs", tex_depth = 3, closed = false);

