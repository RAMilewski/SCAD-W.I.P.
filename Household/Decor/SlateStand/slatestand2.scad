include <BOSL2/std.scad>
$fn = 128;

bez1 = flatten([
    bez_begin ([-25,0,0], 0, 40, p=60),
    bez_tang ([15,0,75], 0, 17, p=60),
    bez_end   ([30,0,0], 0, 25, p=-18)
]);

shape = squircle([15,5]);

path1 = bezpath_curve(bez1, splinesteps = 64);

path_sweep(xscale(1.2, shape), squircle([80,150], squareness = .8, style = "superellipse"), closed = true);


fwd(74) path_sweep(shape,path1);
back(74) path_sweep(shape,path1);
move([43,0,2]) top_half() top_half() zscale(2) ycyl(h = 100, d=7, rounding = 2.5);


//ghost() move([36,0,4]) yrot(-6)cube([7,200,300], anchor = BOT);


//debug_bezier(bez1, N=3);