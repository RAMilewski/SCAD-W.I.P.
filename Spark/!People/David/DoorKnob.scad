include<BOSL2/std.scad>

$fn = 72;

width = 58;
r = 28;
angle = 35;
wall = 4;


path = teardrop2d(r = r, ang = 35 );

//knob();
clamp();

module knob() {
    diff()
        linear_sweep(teardrop2d(r = r, ang = angle ), width) fwd(wall) {
            attach(TOP,BOT) cyl(h = wall, r = r + wall);
            attach(BOT,TOP) cyl(h = wall, r = r + wall)
                position(BOT) tag("remove") 
                    cyl(r = r - wall, h = width + 2 * wall, rounding = -5, teardrop = true,anchor = BOT);
        }
}
module clamp() {
    rect_tube(isize = [width+1, 5], wall = 2 * wall, l = 10, rounding = 10);
}