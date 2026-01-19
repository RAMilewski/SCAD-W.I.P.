include <BOSL2/std.scad>

$fn = 72;

A = 12;     // shelf hole diameter
B = 6;      // shelf slot width
C = 2.5;    // shelf rail thickness
wall = 3;   // hook thickness
base = [35, 25, wall]; 
hook = 25;  // hook diameter
edge = 1;   // rounding radius

xscale(0.5) cyl(d = base.y, h = base.z, rounding = edge, anchor = BOT);
cuboid(base, rounding = edge, edges = "X", anchor = BOT+LEFT)
    position(BOT+LEFT) cyl(d = B, h = C, anchor = TOP)
        position(BOT) cyl(d = A, h = C, rounding = edge, anchor = TOP);
right(base.x){ 
    xrot(90) back(hook/2) hook();
    up(hook - base.z) xscale(0.5) left_half() cyl(d = base.y, h = base.z, rounding = edge, anchor = BOT);
}



module hook() {
    right_half()
        diff() {
            tube(od = hook, wall = base.z, h = base.y) {
                yrot_copies(n=2) {
                    tag("remove") attach(TOP) rounding_cylinder_mask(d = hook, rounding = edge);
                    tag("remove") attach(TOP) rounding_hole_mask(d = hook - 2 * wall, rounding = edge);
                }
            }
        }
}