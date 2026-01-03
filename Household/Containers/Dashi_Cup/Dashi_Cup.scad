include<BOSL2/std.scad>

$fn = 64;
size = [40,90,3];
wall = [3,3,0];
corner = 3;

cuboid(size+wall+wall, rounding = corner, edges = ["Z"])
    position(TOP) rect_tube(isize = [size.x,size.y], wall = size.z, h = 40, rounding = corner, irounding = corner);

//up(43) ruler();