include<BOSL2/std.scad>
$fn = 72;
tube(od = 15, wall = 0.6, h = 15)
    position(TOP) cuboid([40,30,0.5], rounding = 5, edges = "Z");