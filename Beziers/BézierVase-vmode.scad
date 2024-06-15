include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
$fn = 64;
shape = 3;
bez = shapeset[shape];

offset = [1,0];
floor = 1.5;
is2d = false;
half = false;

 
u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);

bez2 = bezpath_close_to_axis(bez, axis = "Y"); 
path = bezpath_curve(bez2, splinesteps = 64);

if (is2d) {
    debug_bezier(bez2, 0.1); 
} else {
    if(half) 
            { back_half(s = 200) rotate_sweep(path,360); } 
        else
            { rotate_sweep(path,360); }
}






/*** Ignore everything below this line.  Here there be dragons.

bez2 = bezpath_close_to_axis(bez, axis = "Y");
debug_bezier(bez);

back_half(s = 300) {
}

*/