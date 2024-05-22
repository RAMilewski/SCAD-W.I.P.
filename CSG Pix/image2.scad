include<BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 144;

color1 = "yellow";
color2 = "goldenrod";



    rounded_prism(rect(30), height=30, splinesteps = 32,
        joint_top=5, joint_bot=5, joint_sides=5, k = 0.5)
        show_anchors();




/*
diff() {
    cuboid(50, rounding = -10, edges = BOT) {
        tag("remove")cyl(h = 50.1, d = 25, rounding2 = -10);
        edge_mask("Z")
            rounding_edge_mask(l = 50.1, r = 10);
    }

}
*/