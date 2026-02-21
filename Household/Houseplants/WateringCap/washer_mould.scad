include <BOSL2/std.scad>

$fn = 72;

d1 = 26;
d2 = 10;
d3 = 2;

base = [100, 35, 1.5];

diff() {
    cuboid(base, rounding = 4, edges = "Z") {
        position(TOP) xcopies(n = 3, l = 65) tube(id = d1, wall = 2, h = 5, anchor = BOT);
        position(TOP) xcopies(n = 3, l = 65) cyl(d = d2, h = 10, rounding1 = -2, rounding2 = 4, anchor = BOT);
        position(TOP) xcopies(n = 3, l = 65) right(d2-1) cyl(d = d3, h = 6, rounding1 = -1.5, rounding2 = 1, anchor = BOT);
        
    }
}