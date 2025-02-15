include <BOSL2/std.scad>
include <BOSL2/screws.scad>

offset = 10;            //distance from wall to handle
handle = [50,4,20];     //handle.x is the doorstop contact length
screw = "6-32,1/2";    //BOSL2 screw spec
corner = 2;

$fn = 32;

diff() {
    cuboid([handle.x,handle.z,offset], rounding = corner, edges = [TOP+LEFT, TOP+RIGHT], anchor = BOT){
        tag("remove") position(TOP) xcopies(n = 2, spacing = handle.x/2)
            #screw_hole(screw, head = "flat",  oversize = 1, counterbore = offset/2, anchor = TOP );
        zrot_copies(n=2) position(BACK+BOT) 
            cuboid([handle.x, handle.y/2, 2 * handle.y + offset], rounding = corner, edges = ["Y"], except = BOT, anchor = BOT+FWD)
                position(TOP+FWD) xcyl(l = handle.x, d = handle.y, rounding = corner, anchor = TOP);
    }
}

