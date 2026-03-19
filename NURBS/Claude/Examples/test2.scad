include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
include <data.scad>


method = "foley";

debug_nurbs_interp_surface(blob3, 2, splinesteps=[32,9], method=method, type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=UP);



