include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
$fn = 72;
shape = 4;
bez = shapeset[shape];

offset = [1,0];
floor = 1.5;
is2d = false;
half = false;

 
u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);

bez2 = bezpath_offset(offset, bez);
path = bezpath_curve(bez2, splinesteps = 64);

if (is2d) {
    debug_bezier(bez2, 0.1); 
} else {
    if(half) 
            { back_half(s = 200) rotate_sweep(path,360); } 
        else
            { rotate_sweep(path,360);}

    cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);
}






/*** Ignore everything below this line.  Here there be dragons.

bez2 = bezpath_close_to_axis(bez, axis = "Y");
debug_bezier(bez);

back_half(s = 300) {
}

*/