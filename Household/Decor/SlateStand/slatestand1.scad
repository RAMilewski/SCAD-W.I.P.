include <BOSL2/std.scad>

$fn = 64;

bez1 = flatten([
    bez_begin([-75,0,0],  BACK, 40),
    bez_joint([0,25,70],  LEFT, RIGHT, 50,50),
    bez_tang ([75,0,0],   FWD, 40),
    bez_joint([0,-50,0], RIGHT, LEFT, 25,25),
    bez_end  ([-75,0,0],  FWD, 40)
]);

bez2 = flatten([
    bez_begin([-75,0,0],  BACK, 40),
    bez_joint([0,50,0],  LEFT, RIGHT, 50,50),
    bez_tang ([75,0,0],   FWD, 40),
    bez_joint([0,-50,0], RIGHT, LEFT, 25,25),
    bez_end  ([-75,0,0],  FWD, 40)
]);

shape = squircle([15,5]);
/*
path1 = bezpath_curve(bez1, splinesteps = 64);
path2 = bezpath_curve(bez2, splinesteps = 64);

path_sweep(shape, path1, closed = true);
path_sweep(shape, path2, closed = true);

back(50)xscale(5) top_half() ycyl(h = 5, d = 15, rounding = 2.5);

back(44) xrot(7.5) ghost() cuboid([150,8,300], anchor = BOT);
*/
debug_bezier(bez1, N=3);
color("blue") debug_bezier(bez2, N = 3);
//color("red") debug_bezier(bez3, N = 3);