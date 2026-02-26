include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>

   data2 = [[0,0], [20,30], [30,90], [36,111], [50,25], [80,0]];

   stroke( nurbs_interp_curve(data2, 3, type="closed", derivs=[undef,undef,undef,undef,undef,undef],
      centripetal=false, splinesteps=32),  width=1,color="red");
   color("black")move_copies(data2)circle(r=2);   
