include<BOSL2/std.scad>

bez = flatten([
    bez_begin([-20,0],   0,30),
    bez_tang ([0.,50],   0,30),
    bez_end  ([20, 0], 180,30),
]);

shape = rect([3,30], rounding = 1, $fn = 32);

//bezier_sweep(shape,bez, splinesteps = 32);


path = bezier_curve(bez, splinesteps = 64);
path_sweep(shape, path);

/* */