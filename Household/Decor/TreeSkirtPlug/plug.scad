include <BOSL2/std.scad>

$fn = 64;
 h = 30;
 d1 = 12;
 d2 = d1 + 2;

cyl(h = h, d1 = d1, d2 = d2, anchor = BOT) {
    position(TOP) zscale(2) torus(r_maj = d2/2, r_min = 0.5);
    position(TOP) cyl(h = h, d1 = d2, d2 = d1, anchor = BOT);
}

