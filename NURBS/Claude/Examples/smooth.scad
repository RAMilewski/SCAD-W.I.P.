include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<data.scad>
include<../nurbs_interp.scad>


debug_nurbs_interp_surface(blob3, 3, type=["clamped","closed"],extra_pts=4,normal1=2*DOWN,normal2=2*UP,data_size=0,splinesteps=[32,16],smooth=2); 
