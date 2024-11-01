include <BOSL2/std.scad>

$fn = 72;

top_plate = [154,99,1.5];
tp_corner = 5;
tp_hole_r = 15;

post_height = 21.5;

post_A1 = [10, 5];
post_A2 = [9, 5];




top();



module top() {
    diff() {
        cuboid(top_plate, rounding = tp_corner, edges = "Z", anchor = BOT){
            tag("remove") cyl(r = tp_hole_r, h = top_plate.z);
            attach(TOP,BOT) fwd(38.5) prismoid(post_A1, post_A2, post_height, rounding2 = 0, edges = "Y", except= "BOT");
        }
    }
}




move([0,100,-25]) xrot(90) import("top.stl");
back(100) up(post_height) yrot(0) zrot(-90)  ruler();