include <BOSL2/std.scad>
$fn = 64;

partition(spread = 15, cutpath = "hammerhead", cutsize = 5, $slop = 0.05)
    cyl(h = 5, d = 50, anchor = BOT);