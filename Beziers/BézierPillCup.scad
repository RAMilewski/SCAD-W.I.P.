include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <shapeset.scad>
$fn = 72;
shape = 4;
//bez = shapeset[shape];

bez = [[10,0],[30,10],[10,20],[17,40]];

bez1 = [[20,0],[30,15],[20,15],[12,25]];

*debug_bezier(bez1, width = 0.2);
*debug_bezier(bez, width = 0.2);

top(); //right(50) base();

offset = [-1.5,0];
floor = 2;
is2d = false;
half = false;
u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);

 
module top() {
    bez2 = bezpath_offset(offset, bez);
    path = bezpath_curve(bez2, splinesteps = 64);
    rotate_sweep(path,360);
    //cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);

        diff(){
            cyl(r = bez[0].x, h = floor*3, anchor = TOP);
            tag("remove") arc_copies(r = 5) cyl(d = 3, h = floor*3+.1, $fn = 6, anchor = TOP);
        }
    
}


module base() {
     bez2 = bezpath_offset(offset, bez1);
    path = bezpath_curve(bez2, splinesteps = 64);
    rotate_sweep(path,360);
    //cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);
    down(floor)cyl(r = bez1[0].x, h = floor, anchor = BOT);
}


/*


bez2 = bezpath_close_to_axis(bez, axis = "Y");
debug_bezier(bez);

back_half(s = 300) {
}

*/