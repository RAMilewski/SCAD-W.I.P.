include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bezpath = flatten([
    bez_begin([20,30], 45,  50),
    bez_joint([20,0],  45, 135, 50,50),
    bez_end  ([20,30], 135,  50),
]);

debug_bezier(bezpath);


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
