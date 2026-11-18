include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

radius = 15;
count = 8;
zspace = 20;
levels = 4;

surface = [ repeat([0,0,zspace],count),
   for(i=[0:levels]) path3d(circle(radius,$fn = count),(i+1)*zspace),
   repeat([0,0,(levels + 1) * zspace],count)
];


nurbs_interp_surface(surface, 3, method = "foley", col_wrap = true);





