include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
surface = [ for(i=[0:4]) zrot(i*15,path3d(star(or=15,ir=10, n=9),i*15)), ];
nurbs_interp_surface(surface, 3, col_wrap = true, caps = true);