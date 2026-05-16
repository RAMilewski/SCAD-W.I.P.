include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

surface = [
    
    [[-50, 50, 0], [-16, 50,  0], [ 16, 50,  0], [50, 50,  0], [80, 50, 0]],
    [[-50, 25, 0], [-16, 25, 40], [ 16, 25, 30], [50, 25, 20], [80, 25, 0]],
    [[-50,  0, 0], [-16,  0, 40], [ 16,  0, 30], [50,  0, 30], [80,  0, 0]],
    [[-50,-25, 0], [-16,-25, 35], [ 16,-25, 40], [50,-25, 15], [80,-25, 0]],
    [[-50,-50, 0], [-16,-50,  0], [ 16,-50,  0], [50,-50,  0], [80,-50, 0]],
];


nurbs_interp_surface(surface,3, first_row_deriv = UP+FWD, last_row_deriv = DOWN+FWD, first_col_deriv = UP+RIGHT/2, last_col_deriv = DOWN+RIGHT/2);
