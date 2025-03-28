include<BOSL2/std.scad>

$fn = 144;

diff() {
    cuboid([40,10,5], rounding = 2, teardrop = true)
        tag("remove") xcopies(n = 7, spacing = 5) #cyl(h = 6, d = 1 + $idx/5, circum = true);
}