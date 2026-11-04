include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

count = 8;

surface = [ repeat([0,0,30],count),
   for(i=[1:5]) path3d(circle(15,$fn = count),i*30),
   repeat([0,0,200],count)
];

nurbs_interp_surface(surface, 3, col_wrap = true);
