

include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>

shape = [ repeat([0,0,-1],8),
           for(i=[0:5]) path3d(regular_ngon(n = 8, side = 15),i*15),
           path3d(regular_ngon(n = 8, side = 50), 5 * 15),
           path3d(regular_ngon(n = 8, side = 55), 6.5 * 15),
           repeat([0,0,8*15],8)
        ];

nurbs_interp_surface(shape, 3, normal1 = DOWN, normal2 = UP, col_wrap = true, row_edges = 7);
/* */