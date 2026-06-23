include<BOSL2/std.scad>
include<nurbs.scad>


stroke(nurbs_curve([[0,0],[0.5,1],[1,0]], 2, splinesteps=5, deriv=[0,1]));
 
echo(nurbs_curve([[0,0],[0.5,1],[1,0]], 2, splinesteps=5, deriv=[0,1])) ;


