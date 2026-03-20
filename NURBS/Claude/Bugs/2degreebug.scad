include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<../nurbs_interp.scad>


blob3 = [ repeat([0,0,-15],18),
           for(i=[0:4]) zrot(i*15,path3d(star(or=20,ir=15, n=9),i*15)),
           repeat([0,0,5*15],18)
        ];
  debug_nurbs_interp_surface(blob3, 2, splinesteps=[32,9], method="centripetal", type=["clamped","closed"],data_size=0,
         normal1=DOWN,normal2=UP);