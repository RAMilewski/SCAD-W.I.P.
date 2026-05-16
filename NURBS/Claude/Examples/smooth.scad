include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<data.scad>

blob = [ repeat([0,0,-15],12),
           for(i=[0:4]) zrot(i*15,path3d(star(or=20,ir=15, n=6),i*15)),
           repeat([0,0,5*15],12)
        ];

nurbs_interp_surface(blob3, 3, col_wrap = true, extra_pts=4,normal1=4*DOWN,normal2=4*UP, 
    flat_end1 = 3, flat_end2 = -3, data_size=0,splinesteps=[32,16],smooth=2); 
