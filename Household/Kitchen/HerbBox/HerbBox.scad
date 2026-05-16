include <BOSL2/std.scad>

$fn = 72;


cuboid([220,120,4], rounding=10, edges = "Z")
position(TOP) rect_tube(size = [220,120], l = 90, rounding = 10, wall = 4);