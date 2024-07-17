include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bezpath = flatten([
    bez_begin([0,15], 35,  30),
    bez_joint([0,-15],  45, 135, 30,30),
    bez_end  ([0,15], 145,  30),
]);

inside = bezpath_curve(bezpath);
stroke(inside, closed = true);

outside = offset(inside, delta = 4, closed = true);
stroke(outside, closed = true);

/*

path = bezpath_curve(bezpath); 
sq = square(1, center = true);

linear_extrude(height = 10, center = true, convexity = 10, twist = 0)
translate([2, 0, 0])
path;

rotate_sweep(path, 360);

path_sweep(sq, path);
linear_sweep(path, h =20);
*/
