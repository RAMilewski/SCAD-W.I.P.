include<BOSL2/std.scad>

$fn = 64;
w = INCH*11/3 + 2;  // for US Letter trifold
d = 25.4;
wall = 2;
corner = 3;

// left_half(s = 200)
diff() {
    rect_tube(isize = [w,d], shift = [0,d/8], wall = wall, h = d, rounding = corner) {
        position(FWD+TOP) tag("remove") cuboid([d,d,d/2], rounding = -d/2, edges = "Y", except = BOT, anchor = TOP)
            position(BOT) zscale(.9) ycyl(h = d, d = d);
        // position(BACK+TOP) xrot(-hyp_opp_to_ang(d,d/8)) #cuboid([w,1,11 * INCH], anchor = BOT); // dummy brochure
        position(BOT) back(15) cuboid([w+2*wall,80,wall], rounding = corner *3, edges = "Z");
        position(BACK+TOP) down(0.5) fwd(0.125) xrot(-hyp_opp_to_ang(d,d/8)) 
            cuboid([d,wall-.05,d*2], rounding = -d/2, edges = "Y", except = TOP, anchor = BOT+BACK)
                 position(BACK+TOP) ycyl(h = wall, d = d, anchor = BACK);
    }
}

echo(hyp_opp_to_ang(d,d/8));