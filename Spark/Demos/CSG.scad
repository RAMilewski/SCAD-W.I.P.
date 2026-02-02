
difference() {
    intersection() {
        color("red") cube(50, center = true);
        color("blue") sphere(d = 65);
    }
    cylinder(h=55, d = 30, center = true);
    rotate([90,0,0]) cylinder(h=55, d = 30, center = true);
    rotate([0,90,0]) cylinder(h=55, d = 30, center = true);
}

include<BOSL2/std.scad>

right(60)

diff() {
    intersection() {
        color("red") cuboid(50);
        color("blue") sphere(d = 65);
    }
    tag("remove") {
        xcyl(h = 55, d = 30);
        ycyl(h = 55, d = 30);
        zcyl(h = 55, d = 30);
    }
}

