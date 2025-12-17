include<BOSL2/std.scad>
include<BOSL2/screws.scad>

$fn = 72;

block = [40,60,4];

od = 15;
id = 11.6;

diff(){
    cuboid(block, rounding = 5, edges = "Z"){
        ycopies(n=2, spacing = block.y *.8) position(TOP) screw_hole("#6,.5", head = "flat", anchor=TOP);
        attach(TOP, BOT) cyl(h = 5, d = od, rounding1 = -3)
            position(TOP) spheroid(d = od)
                attach(TOP+RIGHT, BOT, overlap = id/2) insert();
                    
    }
}

module insert() {
    zrot_copies([0,90]) prismoid([id,1.75], [id-0.5,1.75], h = 25)
        position(TOP) rounding_cylinder_mask(r=id/2, rounding=5);
}