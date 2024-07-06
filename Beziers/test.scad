include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bezpath = flatten([
    bez_begin([0,0], 90, 5),
    bez_joint([0,10],  270,0,   10,10),
    bez_joint([10,10], 180,270, 10,10),
    bez_joint([10,0],  90,180,  10,10),
    bez_end  ([0,0], 0, 20)
]);

debug_bezier(bezpath);





/*
rotate_sweep(path, 360);

path_sweep(sq, path);
linear_sweep(path, h =20);
*/
