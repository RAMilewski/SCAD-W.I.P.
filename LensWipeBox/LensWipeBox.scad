include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
$fn = 36;
pkg = [103,58];
wall = 2;
h = 20;
shelf = [pkg.x+2*wall, (pkg.y * 1.3 + 2 * wall), wall];
slot  = [pkg.x, pkg.y - 10, 5];
diff() {
    cuboid(shelf, rounding = 5, edges = "Z", except= BACK, anchor = BOT){
        align(TOP+BACK) rect_tube(h = h, isize = pkg, wall = wall, anchor = BOT)
           zscale(0.25) align(TOP+BACK) #ycyl(d = shelf.x, h = wall);   
        position(TOP) tag("remove") cuboid(slot, anchor = BOT);
        position(TOP+BACK) tag("keep") fwd(wall) zrot(180) wedge(slot, anchor = BOT+FWD); 
        position(BOT+FWD) xrot(90) tag("remove") rounded_prism(rect([25, slot.z]), height=25, joint_top=-20, joint_bot=2, joint_sides=0, k=0.5, anchor = TOP);
    }
}
