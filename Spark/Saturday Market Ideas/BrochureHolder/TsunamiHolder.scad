include<BOSL2/std.scad>

$fn = 64;
w = INCH*11/3 + 2;  // for US Letter trifold
d = 25.4;
wall = 1.5;
slot = [w * .65, wall * 2, d * 2.5];
corner = 3;
plate = [w * 1.5, 1, d*4];

// left_half(s = 200)
diff() {
    rect_tube(isize = [w,d], wall = wall, h = d * 4, rounding = corner) {
        position(BOT) cuboid([w,d,wall], anchor= BOT);
        position(FWD+TOP) tag("remove") up(0.01) cuboid(slot, rounding = -d/2, edges = "Y", except = BOT, anchor = TOP)
            position(BOT) zscale(.9) ycyl(h = 2 * wall, d = slot.x);
        position(BACK) cuboid(plate, rounding = 5, edges = "Y", anchor = BACK)
            xrot(90) grid_copies(n = [2,3], spacing = [plate.x - 20, d ])
                tag("remove") zcyl(h = wall, d = 3);
    }
}      
