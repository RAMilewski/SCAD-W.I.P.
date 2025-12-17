include<BOSL2/std.scad>

$fn = 72;

d_pad = 15;
z_pad = 3;

d_post = 3;
d_top = 5;
z_post = 3;


cyl(h = z_pad, d = d_pad, rounding = 1)
    position(TOP) cyl(h = z_post, d1 = d_post, d2 = d_top, 
        rounding1 = -1, rounding2 = 1, anchor = BOT);