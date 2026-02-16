include<BOSL2/std.scad>
include<BOSL2/screws.scad>


$fn = 32;
offset = 15;
yshift = 5;
block = [40,40,offset];


mount(); right(50) wall_mount(); //left(50) bumper();

module mount(){
    diff()
        cuboid(block, rounding = 2, except = BOT, anchor = BOT)
            tag("remove")  position(BOT) up(offset * .4) fwd(yshift/2) keystone();
}

module wall_mount(){
    diff() {
        keystone() {
            screw_hole("#6", l = 12, head = "flat", head_oversize = 2, counterbore = 1.5, anchor = TOP, orient = DOWN);
        }
    }
}

module keystone (anchor = TOP, spin = 0, orient = DOWN) {
    skin(
    [trapezoid(h = block.y - yshift, w1 = block.x * .9, w2 = block.x * .5),
     fwd(yshift/2, trapezoid(h = block.y - yshift * 2, w1 = block.x * .8, w2 = block.x * .4))],
     z = [0,offset * .6], slices = 2);   
     children(); 
}

module bumper (anchor = BOT, spin = 0, orient = UP) {
    cuboid([block.x/2, block.y/2, block.z], rounding = 2, except = BOT, anchor = BOT);
}