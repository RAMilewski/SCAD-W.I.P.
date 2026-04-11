include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<data.scad>
include<../nurbs_interp.scad>


arc1 = arc(angle=[-120,120], r=30, n=9);
arc2 = arc(points=[arc1[0], [20,0], last(arc1)],n=9);
p=(concat(select(arc1,1,-2),select(reverse(arc2),2,-3)));
allp = [for(z=[0:6]) yscale(1+z^2/70,path3d(p,10*z))];
debug_nurbs_interp_surface(allp, 3, type=["clamped","closed"],flat_end1=1,flat_end2=2,extra_pts=4,data_size=0,splinesteps=[32,16]);


