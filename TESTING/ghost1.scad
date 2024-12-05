include <BOSL2/std.scad>

$fn = 64;

color_overlaps() {
    cuboid(30)
     ghost(false) cuboid(10);
}