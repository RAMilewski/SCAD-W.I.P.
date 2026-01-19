

include<BOSL2/std.scad>

//scale(25.4) yrot(180) #import("adapter_sides_2inch.stl");

$fn = 72;
ring = [44.5,13,3];
key = [8,13];
tab = [2.5,2.5,3];




tube(or = ring.x, ir =ring.y, h = ring.z) {
    ycopies(n = 2, spacing = 2 * ring.y - tab.y/2) cuboid(tab);
    position(TOP) {
        tube(od1 = 55, od2 = 52, wall = 3, h = 9.7, $fn = 64, anchor = BOT);
        left(38) prismoid(key, key-[0.5,0.5], h = 3, rounding1 = 4, rounding2 = 3.75, $fn = 64, anchor = BOT);
    }f
}

//back(11) left(1.3) ruler();