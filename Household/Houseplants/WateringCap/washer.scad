include <BOSL2/std.scad>

$fn = 72;

d1 = 26;
d2 = 14;
d3 = 3.5;
h = 3.5;

base = [100, 35, 1.5];

diff() {
        cyl(d = d1, h = h, rounding = 1, teardrop = true) {
            tag("remove") cyl(d = d2, h = h, rounding = -1);
            tag("remove") right(d2/2 + 3) cyl(d = d3, h = h, rounding = -0.5);
        }
    }
