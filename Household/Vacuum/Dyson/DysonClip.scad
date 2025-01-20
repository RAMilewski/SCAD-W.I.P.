include <BOSL2/std.scad>

$fn = 72;

wall = 3;
height = 10;

diff() {
    tube(id = 35, wall = wall, h = height){
        tag("remove") align(LEFT, overlap = wall) cuboid([wall * 3,0.5, height + 1]);
        align(LEFT, overlap = 1) cuboid([5,5,height], rounding = 1, edges = "Z", except= RIGHT);
        attach(RIGHT,LEFT, overlap = wall) tube(id = 8, wall = wall, h = height)
            tag("remove") align(RIGHT, overlap = wall) cuboid([wall,0.5, height + 1]);
        left(22.5) xscale(0.5) tag("remove") ycyl(h = 6, d = 4);
        right(20) xscale(0.5) tag("remove") ycyl(h = 25, d = 4);
    }        
}