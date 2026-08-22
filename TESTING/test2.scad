include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
thickness = 3;
star_pts = star(or=25, ir=21, n=7);
surface = [ for(i=[0:4]) zrot(i*10,path3d(star_pts,i*5)), ];
S = nurbs_interp_surface(surface, 3, col_wrap=true);
sheet = nurbs_sheet(S, delta=[0, -thickness]);
star_region = [nurbs_curve(nurbs_interp(star_pts, 3, closed=true))];
cap = linear_sweep(star_region, thickness, anchor=BOT);
vnf_polyhedron(vnf_join([sheet, cap]));


