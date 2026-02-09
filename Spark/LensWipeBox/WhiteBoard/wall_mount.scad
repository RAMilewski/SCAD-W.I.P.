include<BOSL2/std.scad>
include<BOSL2/screws.scad>


$fn = 32;
offset = 10;
yshift = 5;
block = [40,40,offset];


mount(); right(50) wall_mount();

module mount(){
    diff()
        cuboid(block, rounding = 2, teardrop = true, anchor = BOT)
            tag("remove")  position(BOT) up(offset * .2) fwd(yshift/2) #keystone();
}

module wall_mount(){
    diff() {
        keystone() {
            #screw_hole("#6", l = 12, head = "flat", head_oversize = 2, counterbore = 1.5, anchor = TOP, orient = DOWN);
        }
    }
}

module keystone (anchor = TOP, spin = 0, orient = DOWN) {
    skin(
    [trapezoid(h = block.y - yshift, w1 = block.x * .9, w2 = block.x * .5),
     trapezoid(h = block.y - yshift, w1 = block.x * .6, w2 = block.x * .2)],
     z = [0,offset * .8], slices = 2);   
     children(); 
   
}