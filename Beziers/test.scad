include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<BOSL2/rounding.scad>

cyl(10, 20, $fn = 6);
zrot_copies(n = 3, sa = 30) #cuboid([40,2,12]);