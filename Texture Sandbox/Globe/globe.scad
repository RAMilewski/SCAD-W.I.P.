include<BOSL2/std.scad>
include<BOSL2/examples/worldmap_360x180.scad>
$vpr = [70,0,-360*$t];
color("blue") spheroid(20.007, $fn = 256);
rotate_sweep(arc(r = 20, n = 129, start = -90, angle = 180), 360, 
    texture = worldmap, tex_depth = 0.5, tex_reps = [1,1]);