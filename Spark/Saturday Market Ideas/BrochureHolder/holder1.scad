include<BOSL2/std.scad>

$fn = 32;
w = INCH*11/3;
d = 25.4;
wall = 2;
corner = 3;


diff() {
    rect_tube(isize = [w,d], shift = [0,d/4], wall = wall, h = d, rounding = corner) {
        position(FWD+TOP) xscale(w/d) tag("remove")ycyl(h = 10, d = d);
        position(BOT) cuboid([w+2*wall,d*2,wall], rounding = corner, edges = "Z");
        position(BACK) zscale(3)  xrot(-39) ycyl(h = wall-.35, d = d, anchor = BOT+BACK);
    }
}

