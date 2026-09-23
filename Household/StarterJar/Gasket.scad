
include <BOSL2/std.scad>

$export_name = "StarterJarGasket";

$fn = 72;

id = 77;
wall = 10;
h = 3
tab=20;


tube(id = id, wall = wall, h = h)
   position(RIGHT) cyl(h = h, d = tab);
