include <BOSL2/std.scad>
include <20x20S.txt>
 

cuboid(20)
    position(TOP) heightfield(custom, size = [20,20], bottom = 0, maxz = 1);