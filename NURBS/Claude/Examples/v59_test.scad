include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../Archive/nurbs_interp_old.scad>

data = regular_ngon(8,100);
a=nurbs_interp(data,3,type="closed",method="centripetal",
                   deriv=[DOWN*1.04,undef,undef,undef,undef,undef,undef,undef]);
stroke(nurbs_curve(a,splinesteps=16));
