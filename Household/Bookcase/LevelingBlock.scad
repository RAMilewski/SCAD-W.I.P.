include <BOSL2/std.scad>

block= [80, 56, 25];
gap = [18, 18, 15];

$fn = 72;

diff(){
        cuboid(block, rounding = 2)
            position(FWD+TOP) tag("remove") #cuboid(gap, rounding = -2, edges = TOP, anchor = FWD+TOP);
}