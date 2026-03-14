include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <archive/nurbs_interp-v33.scad>

pts = [for(i=[0:5]) path3d(scale(sqrt(i*(5-i)),random_polygon(n=5, size=[15,20])),10*i)];
v=   nurbs_interp_vnf(pts, 3, splinesteps=16,  type=["clamped","closed"],
     start_u_der = 3*reverse(pentagon(r=1)),
     end_u_der = -3*reverse(pentagon(r=1)),     
     );
vnf_polyhedron(vnf_reverse_faces(v));

