include <BOSL2/std.scad>
$fn = 72;

cyl(d = 21, h = 15, anchor = BOT)
    attach(TOP) cyl(d1 = 21, d2 = 60, h = 40, anchor = BOT);