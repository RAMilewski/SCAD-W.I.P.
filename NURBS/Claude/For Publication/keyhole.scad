include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>


data = [[0,0],[0,10],[-5,20],[5,30],[15,20],[10,10],[10,0],[0,0]];


debug_nurbs_interp(data,3, method="centripetal",
    deriv=[undef,NAN,UP,RIGHT*1.3,DOWN,NAN,NAN,undef],
    curvature=[undef,undef,undef,-.1,undef,undef,undef,undef],
    extra_pts = 1, smooth = 3
    );

