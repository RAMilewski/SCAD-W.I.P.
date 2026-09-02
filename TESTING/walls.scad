include <BOSL2/std.scad>


//zrot(180/12)
tube(h = 10, ir = 20, wall = 3, ifn = 4, $fn = 144, circum = true);

up(5) color("red") cyl(h=1, r = 20, circum = true, $fn = 144);