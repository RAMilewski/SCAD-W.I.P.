include <BOSL2/std.scad>


translate([0, 0, -1]) cuboid(10)
    position(RIGHT) recolor("blue") xcyl(h = 10, d = 10);