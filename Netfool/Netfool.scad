include<BOSL2/std.scad>
include<data>

$fn = 72;

heightfield(data = data, size = 40, bottom = -1, style = "default");

right(50)
linear_sweep(circle(r=20), orient = BACK,  scale=1, texture=data, tex_reps=[2,1], h=40);