include<BOSL2/std.scad>
include<data.scad>

$fn = 72;

cuboid([90,40,0.25], anchor = BOT)
    attach(TOP)
        heightfield(data, size = [90,40], bottom = -1e-12, maxz = 1);

back(25) left(30)
    linear_sweep(circle(d = 90/PI), h = 40, texture = data, tex_reps = [1,1]);

back(25) right(30)
   cyl(d = 90/PI, h = 40, texture = data, tex_reps = [1,1], anchor = BOT);


