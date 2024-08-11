include<BOSL2/std.scad>

right(300) {
$fn = 80;

circ = circle( r = 90);
circ2 = circle( r = 88);

skin([circ, rot(120,p = circ), rot(120,p=circ2), circ2], z = [-180,180,180,-180], slices = 20);


}