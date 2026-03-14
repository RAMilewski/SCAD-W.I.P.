include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>


deg = 3;
type="clamped";

data2 = [[0,0], [12,12], [20,30], [30,90], [36,111],[50,25], [80,0], [45,-12],[30,-32]];

debug_nurbs_interp(data2, deg, type=type, method="centripetal",
               deriv=[undef,undef,undef,undef,NAN,undef,undef,undef,undef]);


