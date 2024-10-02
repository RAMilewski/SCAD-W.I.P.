include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
include <BOSL2/rounding.scad>

$fn = 64;

coin = [45,undef,7];
base = [70,20,3];
r1 = (base.x)/2;
r2 = 10;
cz = r2/2;

function cpd(r) = r * (4/3) * tan(180/8); // Control pt distance for quarter round.

bez = flatten([
    bez_begin([r1-r2*2, 0], -90, cpd(r2)),
    bez_tang ([r1-r2,-r2], 0, cpd(r2)),
    bez_tang ([r1,0], 90, cpd(r2)),
    bez_tang ([r1-r2, r2], 180, cpd(r2)),
    bez_end([0,cz], 0, 12),
]);

path = offset_stroke(bezier_curve(bez, splinesteps = 32), [-3,0]);

diff() {
    xflip_copy() linear_sweep(path,12, center = true);
    tag("remove") back(coin.x/2+cz) #cyl(d = coin.x, h = coin.z);
}