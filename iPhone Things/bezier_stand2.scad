include<BOSL2/std.scad>

bez = flatten([
    bez_begin([-52,  5],  -45,1),
    bez_tang ([-40,  0],   0, 11),
    bez_tang ([-6.5, 49],  0,12),
    bez_end  ([  2,  0],  90,10),
]);

shape = rect([3,50], rounding = 0.5 );

path = bezpath_curve(bez, splinesteps = 32);

path_sweep(shape,path);
//bezier_sweep(shape,bez,splinesteps = 32);

