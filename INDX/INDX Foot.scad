include <BOSL2/std.scad>

$export_name = "foot";8

diff() {    
    cuboid([20,40,10], chamfer = 1, edges = TOP)
        position(TOP) tag("remove") ycyl(h = 40, d = 6.5, $fn = 72);
}