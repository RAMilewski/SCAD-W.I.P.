include<BOSL2/std.scad>
include<BOSL2/screws.scad>

$fn = 64;

width = 58;
r = 28;
angle = 45;
wall = 4;
d_insert = 4.5;



knob();

fwd(70)clamp();

module knob() {
    diff()
        linear_sweep(teardrop2d(r = r, ang = angle ), width) fwd(wall/2) {
            attach(TOP,BOT) cyl(h = wall*2, r = r + wall);
            attach(BOT,TOP) cyl(h = wall*2, r = r + wall)
                position(BOT) tag("remove") 
                    cyl(r = r - wall, h = width + 4 * wall, rounding = -5, teardrop = true,anchor = BOT)
                        position(BACK) zcopies(n = 2, width + 2 * wall) 
                            #screw_hole("M3","socket", l= 8, orient = FWD, counterbore = 3 ,anchor = TOP);   
        } 
}

module clamp() {
    diff() {
        rect_tube(isize = [width+1, 5], wall = 2 * wall, l = 8, rounding = 10){
            position(TOP) xrot(45) tag("remove") cuboid([width+1, 3 * wall, 3 * wall]);
            xcopies(n = 2, width + 2 * wall) tag("remove") cyl(h = 10, d = d_insert);
        }
    }
}