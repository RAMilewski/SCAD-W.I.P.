include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
include <data.scad>


surface = nurbs_interp_surface(select(blob3,1,-2), 3, type=["clamped","closed"],flat_end1=2.5,flat_end2=2.5);

nurbs_vnf(surface,splinesteps=[32,8],caps=true);