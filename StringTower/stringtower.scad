include<BOSL2/std.scad>

$fn = 72;

diff() {
    conv_hull() 
        xcopies(n = 2, l = 25) cyl(d = 12, h = 1.2, rounding2 = 1, anchor = BOT) {
            position(TOP) tag("keep") tube(id = 3, wall = 1.2, h = 15, anchor = BOT);
        }
    *tag("remove") xscale(-1)  
        text3d("6 / 50%", font="Arial Black", size = 3.5, h = 1, atype = "ycenter", anchor = BOT);
}