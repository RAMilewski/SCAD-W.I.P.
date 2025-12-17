include<BOSL2/std.scad>
include<BOSL2/screws.scad>

$fn = 72;
block = [25,45,20];
hole = [45,38.5,14];
insert = [5,5,5];

diff() {
    cuboid(block, rounding = 10, edges = "X")
        position(BOT) tag("remove") screw_hole("1/4-20,.5", thread = true, bevel2 = true, anchor=TOP, orient = DOWN);
        tag("remove") up(2)cuboid(hole, rounding = 7, edges = "X")
            position(TOP) scale([2,2,0.5]) tag("keep") spheroid(2);
}
