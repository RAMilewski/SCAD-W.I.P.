include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

 data = [[0,0], [10,30], [25,15], [40,35], [60,10], [80,25]];
//path = nurbs_curve(nurbs_interp(data, 3, 
debug_nurbs_interp(data, 3, 
    deriv = [undef,undef,undef,RIGHT/5,undef,undef],
    curvature = [undef,undef,undef,-3,undef,undef],
    extra_pts = 3, smooth = 3
);

//stroke(path);