include<BOSL2/std.scad>

block = [40,18,5];
groove = [30,2.3,3];
hole = 7.8;

diff() {
    cuboid(block, rounding = 1, edges = "Z")
        tag("remove") position(TOP+RIGHT) #cuboid(groove, anchor = TOP+RIGHT);
        tag("remove") cyl(h = block.z, d = hole, $fn = 36);
}