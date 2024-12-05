include <BOSL2/std.scad>

$fn = 64;

mount = [14,14,4.75];
foot = [30,30,10];

diff() {
    cyl(d = foot.x, h = foot.z, rounding1 = foot.z/2, teardrop = false)
        tag("remove") position(TOP) up(0.1) #cyl(d = mount.x, h = mount.z, anchor = TOP);
}
