include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
$fn = 64;
shape = 0;
bez = shapeset[shape];

offset = [2,0];
floor = 2;
 
u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);

bez2 = bezpath_offset(offset, bez);
path = bezpath_curve(bez2, splinesteps = 64);

rotate_sweep(path,360);
cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);







/*** Ignore everything below this line.  Here there be dragons.

/*
bez2 = bezpath_close_to_axis(bez, axis = "Y");
debug_bezier(bez);

back_half(s = 300) {
}
include <TEX/texture.data>
rotate_sweep(path,360, texture = texture, tex_reps = [20,1], tex_depth = -0.5);

*/