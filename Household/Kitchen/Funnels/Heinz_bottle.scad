include<BOSL2/std.scad>

$fn = 72;
cyl(d1 = 70, d2 = 23, h = 30)
    position(TOP) cyl(d = 23, h = 20, anchor = BOT);