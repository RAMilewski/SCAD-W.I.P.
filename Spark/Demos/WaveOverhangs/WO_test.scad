include<BOSL2/std.scad>

$fn = 64;

cyl(h = 3, d = 15)
    position(TOP) cyl(h = 10, d = 10, anchor = BOT)
        position(TOP) cyl(h = 3, d = 25, anchor = BOT);
        