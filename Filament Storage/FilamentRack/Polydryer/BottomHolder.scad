include <BOSL2/std.scad>

$fn = 72;
size = [104,34];
depth = 25;
wall = 1.5;
wing = 5;
corner = 5;

rect_tube(h = depth, size, wall = wall, rounding = corner){
    position(BOT) cuboid([size.x,size.y,wall], rounding = corner, edges = "Z", anchor = BOT);
    position(TOP) rect_tube(size = size + [0.01, 2*wing], isize = size, h = wall, rounding = corner, irounding = corner, anchor = TOP);
}