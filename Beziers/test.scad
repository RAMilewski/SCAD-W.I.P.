include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
$fn = 64;

bez = [[5,0], [15,10], [0,5], [5,15]];
bez2 = bezpath_offset([1,0], bez);
//debug_bezier(bez, N=len(bez)-1);
echo(bez);
path = bezpath_curve(bez2, splinesteps = 64);

back_half(s = 300) 
scale(5) 
    rotate_sweep(path,360);
    color("red") cyl(d1 = 50, d2 = 60, h = 5, anchor = BOT);




/*
bez2 = bezpath_close_to_axis(bez, axis = "Y");
*/