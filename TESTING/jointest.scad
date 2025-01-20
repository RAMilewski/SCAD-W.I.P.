include <BOSL2/std.scad>
$fn = 64;


diff()
    cyl(h = 20, d=10)
    tag("remove") right(6) ycyl(h = 10, d = 10);