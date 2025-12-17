include<BOSL2/std.scad>

$fn = 72;

od = 24.5;
id = 22;

diff() {
    cyl(d1 = od, d2 = od - 0.25, h = 25)
        tag("remove") cyl(d = id, h = 25, rounding2 = -1);
}