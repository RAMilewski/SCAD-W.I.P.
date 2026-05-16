include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

surface = [ repeat([0,0,-15],14),
           for(i=[0:4]) zrot(i*15,path3d(star(or=15,ir=12, n=7),i*15)),
           repeat([0,0,5*15],14)
        ];

nurbs_interp_surface(surface, 3, col_wrap = true, normal2 =  2*RIGHT + 3*UP);

right(35)

nurbs_interp_surface(surface, 3, col_wrap = true, normal2 = 2 * RIGHT + 3*DOWN);