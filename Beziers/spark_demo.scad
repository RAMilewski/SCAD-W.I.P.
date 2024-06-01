include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
$fn = 64;

bez = [[10,0], [50,50], [-20,50], [20,100]];
bez2 = bezpath_offset([3,0], bez);
path = bezpath_curve(bez2, splinesteps = 64);
rotate_sweep(path,360);
cyl(d1 = 20, d2 = 27, h = 3, anchor = BOT);



/*
back_half(s = 300) {
}
debug_bezier(bez, N=len(bez2)-1);
bez2 = bezpath_close_to_axis(bez, axis = "Y");
*/