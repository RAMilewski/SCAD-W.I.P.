include <BOSL2/std.scad>
include <BOSL2/hinges.scad>



part = "box";   // [box, lid, frame]

/* [Hidden] */
$fn = 36;
box = [70,70,50];
wall = 2;
frame = [box.x + 2.5 * wall, box.y + 2.5 * wall, wall * 2.5];
frame_inset = box + [1, 1, -box.z + wall * 2.5];
frame_cutout = box - [1, 1, box.z - 2];
frame_lift = 1;
lid_base = frame_cutout + [-3, -3, 3];
lid = frame_inset + [wall*2, wall*2, 8];
  


//back_half()
if (part == "box") box();
if (part == "lid") lid();
if (part == "frame") frame();


module lid() {
 
    cuboid(lid_base, rounding = wall,  teardrop = true, edges = BOT, anchor = BOT)
        attach(TOP)
            diff() {
                cuboid(lid, rounding = wall, edges = "Z", anchor = BOT) {
                edge_profile(TOP)
                    mask2d_ogee([
                        "xstep",2,  "ystep",2,  // Starting shoulder.
                        "fillet",3, "round",3,  // S-curve.
                        "ystep",1,  "xstep",1   // Ending shoulder.
                    ]);
                }
            }
    x = 58/400;
    up(lid_base.z + lid.z)
    scale([x,x,1/300])
    surface(file = "4corners.dat", center = true);
}


module box() {
    yrot(180) {
        diff() {
            union() {
                cuboid([box.x + 2 * box.z, box.y, wall], anchor = BOT)
                ycopies(n = 2, spacing = box.y + box.z) cuboid([box.x, box.z, wall]);
            }
            zrot_copies(n = 4, d = box.x) tag("remove") 
                #living_hinge_mask(l=box.x + 2 * box.z, thick=wall, foldangle=90, layerheight = 0.2, spin = 90);

        }
    }
    zrot_copies(n = 4, d = box.x + box.z) {
        zrot(-90)
    // heightfield(Cupid2, size = [40,32], bottom = 0 , maxz = 0.4);
    scale([.1,.1,.005]) surface(file="cupid.dat", center = true, convexity = 10 );
    }
}

module frame() {
    diff() {
        cuboid(frame, rounding = wall, teardrop = true, anchor = BOT);
        tag("remove") down(0.05) cuboid(frame_cutout,  anchor = BOT);
        up(frame_lift) tag("remove") cuboid(frame_inset,  anchor = BOT);
    }
}  

 