include<BOSL2/std.scad>


$fn = 72;
od = 69.5;
id = 56;
h = 14;


tube(h = 2, id = id, od = od)
    position(TOP) tube(h=h, od = od, wall = 1, anchor = BOT);