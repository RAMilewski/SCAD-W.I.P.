include <BOSL2/std.scad>

$fn = 72;

corner = 1.5;
length = 100;

base = [length,35,2];
guide = [length,3,9];


diff() {
    cuboid(base, rounding = corner, edges = "Z"){
        align(TOP+BACK) fwd(6.25) ycopies(n = 2, spacing = 6.5)cuboid(guide, rounding = corner, except = BOT, anchor = BOT+BACK);
        tag("remove") xcopies (n = 3 , spacing = length/3) cyl(h = 3, d = 3);
    }
}