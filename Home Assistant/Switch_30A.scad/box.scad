include <BOSL2/std.scad>
include <BOSL2/screws.scad>

part = "lid"; // [lid, box, all]
$fn = 64;
box = [160,75,40];
interior = box - [8,8,5];
lid = interior - [0,0,32];
C14 = [8,31,22.5];
C14_mount = 40;
NEMA15 = [8,24,22];


if (part == "lid") lid();
if (part == "box") box();
if (part == "all") {fwd(50) down(box.z/2) lid(); back(50) box();}

$export_name = str("Switch_30A_",part);

module lid() {
    diff() {
        cuboid(lid, rounding = 5, edges = "Z", anchor = BOT){
            position(LEFT+FWD) right(54.3) back(17.3)
                tag("remove") cyl(d = 8, rounding2 = lid.z, h = lid.z +1);
            grid_copies(n = [2,2], spacing = [box.x - 17, box.y - 17])
                tag("remove") cyl(d = 4, h = lid.z+1);
            align(TOP,[FWD,BACK]) tag("keep")
                cuboid([110,4,10], rounding = 10, 
                    edges = [TOP+LEFT, TOP+RIGHT]);
        }
    }
}

module box() {    
    diff() {
        cuboid(box,rounding = 5, teardrop = true) { 
            position(TOP) tag("remove") {
                // Interior void
                cuboid(interior, chamfer=15, edges = "Z", anchor = TOP);
                // Void for Lid
                cuboid(lid, rounding = 5, edges = "Z", anchor = TOP);
                // Lid Mounting Holes
                grid_copies(n = [2,2], spacing = [box.x - 17, box.y - 17])
                    screw_hole("M3x1", l = 20);
                    
            }
            // Hole for C14 Connector
            position(RIGHT) tag("remove") {
                cuboid(C14, rounding = 5, edges = "X");
                left(4) C14_cutout();
                ycopies (n = 2, l = 40) xcyl(l = 8, d = 3.5);
            }
            // Hole for NEMA 15-5 Connector
            position(LEFT) tag("remove") {
                cuboid(NEMA15);
            }
            // Recess for Switch
            position(BOT) up(2) tag("remove") cuboid([89,56.5,8], anchor = BOT)
            xflip_copy() position(RIGHT) 
                rot([90,0,90]) prismoid([40.1,8],[29,8], 11);
        }
    }
}


module C14_cutout() {
        hull() {
            cuboid(C14, rounding = 5, edges = "X", anchor = RIGHT);
            ycopies(n=2, l = 40) xcyl(h=15, d = 14, anchor = RIGHT);
        }
    
}
