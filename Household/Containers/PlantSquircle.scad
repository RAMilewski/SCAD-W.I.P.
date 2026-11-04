include <BOSL2/std.scad>
$fn = 144;

paths = [
for(i=[0:2]) squircle(190+i*2,0.4),
for(i=[2:-1:0]) squircle(182+i*2,0.4),
];


skin(paths, z = [0,2,50, 50,10,4], slices = 0, refine = 1);
     

