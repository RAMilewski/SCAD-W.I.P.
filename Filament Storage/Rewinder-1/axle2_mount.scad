include<BOSL2/std.scad>

block = [40,18,5];
groove = [20,2.3,3];
hole = 7.8;

diff() {
    cuboid(block, rounding = 1, edges = "Z")
        tag("remove") position(TOP+RIGHT) #cuboid(groove, anchor = TOP+RIGHT);
        tag("remove") down(.75) cyl(h = block.z, d = hole, rounding = -2, $fn = 36);
}
