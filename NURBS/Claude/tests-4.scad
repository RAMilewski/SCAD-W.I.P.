include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
shape = [ 
      for(i=[0:6]) path3d(regular_ngon(n = 8, side = 15),i*15),
        path3d(regular_ngon(n = 8, side = 50), 5 * 15),
        path3d(regular_ngon(n = 8, side = 55), 6.5 * 15),
        repeat([0,0,9*15],8)
        ];

color_this("skyblue") cyl(d = 39.2, h =20, $fn=64, circum = false)
    position(TOP)
        nurbs_interp_surface(shape, 3, normal2 = UP*0.8, splinesteps = 8, col_wrap = true, row_edges = 7);