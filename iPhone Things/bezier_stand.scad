include<BOSL2/std.scad>

bez1 = flatten([
    bez_begin([-52,  5],  -45,1),
    bez_tang ([-40,  0],   0, 11),
    bez_tang ([-6.5, 49],  0,12),
    bez_end  ([  2,  0],  90,10),
]);

bez2 = flatten([
    bez_begin([-52, 9], -40,1),
    bez_tang ([-41, 2],  0,9),
    bez_tang ([-6,  52],  0,15),
    bez_end  ([  5,  0], 92,10),
]); 

path1 = bezpath_curve(bez1, splinesteps = 64);
path2 = bezpath_curve(bez2, splinesteps = 64);
path = concat(path1,reverse(path2));

//debug_bezier(bez1);
//debug_bezier(bez2);

linear_sweep(path, 45);