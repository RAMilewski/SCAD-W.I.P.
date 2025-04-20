include<BOSL2/std.scad>

$fn = 72;

bez = [[15,0], [40,40], [-20,50], [20,80]];
closed = bezpath_offset([2,0], bez);
path = bezpath_curve(closed, splinesteps = 64); 

rotate_sweep(path,360, $fn = 72);
right(60) rotate_sweep(path,360, $fn = 12);
right(120) rotate_sweep(path,360, $fn = 3);


