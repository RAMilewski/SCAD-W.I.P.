include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
$fn = 36;
pkg = [103,63]; // includes 5mm y slop.
wall = 2;
h = 150;
shelf = [pkg.x+2*wall, (pkg.y * 1.3 + 2 * wall), wall];
slot  = [pkg.x, pkg.y - 10, 8];
wallmount = true;


diff() {
    // floor
    cuboid(shelf, rounding = 5, edges = "Z", except= BACK, anchor = BOT){
    // side walls
        align(TOP+BACK) rect_tube(h = h, isize = pkg, wall = wall, anchor = BOT) {
    // keyhole
            if (wallmount) align(TOP+BACK) back(1) down(20) tag("remove") keyhole();
    // front loading slot
            position(TOP) fwd(pkg.y/2) tag("remove") rounded_prism(rect(25), h = h - 25, 
                joint_top = -25, joint_bot = 12, joint_sides = 0, k=0.7, anchor = TOP );
        }
    // front stops
        position(FWD) back(3) xcopies( n = 2, l = shelf.x/3*2 + 3) top_half() 
            zscale(3) xcyl(d = 3, h = shelf.x/4, rounding = 1.5);
    // vending slot
        position(TOP) tag("remove") cuboid(slot, anchor = BOT);
    // floor wedge
        position(TOP+BACK) tag("keep") fwd(wall) zrot(180) wedge(slot, anchor = BOT+FWD); 
    // bottom unload slot    
        position(BOT+FWD) xrot(90) tag("remove") 
            rounded_prism(rect([25, slot.z]), height=35, 
            joint_top=-20, joint_bot=2, joint_sides=0, k=0.7, anchor = TOP);
    }
}

module keyhole() {
    ycyl(d = 10, h = 2 * wall);
    up(7) conv_hull() zcopies(n = 2, l = 8) ycyl(d = 4, h = 2 * wall);
}
