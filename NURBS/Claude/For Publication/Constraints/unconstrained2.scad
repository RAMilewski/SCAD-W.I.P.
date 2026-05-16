include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

data = [[0,0], [20,30], [35,120], [50,30], [70,0]];

debug_nurbs_interp(data, 3, closed = true, 
extra_pts = 3, smooth = 1,
deriv = [UP,undef, RIGHT/3, undef, DOWN]);
 