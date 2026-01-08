include<BOSL2/std.scad>

base = [75,107,8];
spacing = [54,95];
dia = 9;
$fn = 32;

diff() {
    cuboid(base, rounding = 1){
        grid_copies(spacing = spacing, n = 2) tag("remove") cyl(h = base.z, d = dia, rounding2 = -1);
        tag("remove") cuboid([spacing.x+dia/2, spacing.y+dia/2, base.z+0.1], rounding = -1, edges = [TOP,BOT]);
    }
}