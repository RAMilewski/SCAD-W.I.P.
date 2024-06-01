include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
$fn = 64;
bez = [[10,0], [20,45], [5,50], [12,75]];
//debug_bezier(bez, N=len(bez)-1);
cpath = bezpath_close_to_axis(bez, axis = "Y");
path = bezpath_curve(cpath, splinesteps = 64, N = len(bez)-1 );
    diff() {
        rotate_sweep(path,360, $fn = 6)
            position(TOP) tag("remove") cyl(d = 7, h = 13, rounding2 = -1, anchor = TOP, $fn = 72);
    }




/*

back_half(s = 200) 
cyl(d1 = 19, d2 = 21, h = 1, anchor = BOT);
closed = bezpath_offset([-1,0], bez);
debug_bezier(closed);

*/