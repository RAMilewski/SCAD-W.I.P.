include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

data = [[0,21],[6,15],[3,10],[3,0],[-3,0],[-3,10],[-6,15]];

debug_nurbs_interp(data, 3, closed = true, data_size = 0.5,
    deriv = [RIGHT,DOWN*1.5,[-1,-1],NAN,NAN,[-1,1],UP*1.5],
    curvature = [-0.17,-0.17, undef, undef, undef, undef,-0.17],
    extra_pts = 6, smooth = 1
);