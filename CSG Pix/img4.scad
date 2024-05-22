include <BOSL2/std.scad>
include <BOSL2/gears.scad>
$vpd = 700;
$vpr = [45,0,45];
$fn=128;
rteeth=56; pteeth=16; cteeth=24;
circ_pitch=5; thick=10; pa=20;
gd = gear_dist(circ_pitch=circ_pitch, cteeth, pteeth);
ring_gear(
    circ_pitch=circ_pitch,
    teeth=rteeth,
    thickness=thick,
    pressure_angle=pa);
for (a=[0:3]) {
    zrot($t*90+a*90) back(gd) {
        color("goldenrod")
        spur_gear(
            circ_pitch=circ_pitch,
            teeth=pteeth,
            thickness=thick,
            shaft_diam=5,
            pressure_angle=pa,
            spin=-$t*90*rteeth/pteeth);
    }
}
zrot($t*90*rteeth/cteeth+$t*90+180/cteeth)
spur_gear(
    circ_pitch=circ_pitch,
    teeth=cteeth,
    thickness=thick,
    shaft_diam=5,
    pressure_angle=pa);
