include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<data.scad>
include<../Archive/nurbs_interp-v129.scad>


debug_nurbs_interp_surface(blob3, 3, v_edges=3, type=["clamped","closed"],data_size=0,splinesteps=[32,16]);
