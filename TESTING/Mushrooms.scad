include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
shape = [ repeat([0,0,-1],8),
      for(i=[0:5]) path3d(regular_ngon(n = 8, side = 15),i*15),
        path3d(regular_ngon(n = 8, side = 50), 5 * 15),
        path3d(regular_ngon(n = 8, side = 55), 6.5 * 15),
        repeat([0,0,9*15],8)
        ];

for (i = [0.2:0.2:1.8]) {
    right(-800 + i * 800){
        nurbs_interp_surface(shape, 3, normal1 = DOWN, normal2 = UP*i, col_wrap = true, row_edges = 7);
        up(150) xrot(90) color("blue") text3d(str("UP * ",i), size = 14, anchor = CENTER);
    }
}