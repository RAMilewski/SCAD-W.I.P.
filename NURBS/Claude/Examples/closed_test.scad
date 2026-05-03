include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <data.scad>
include <../nurbs_interp.scad>

method="centripetal";   // [centripetal,dynamic,foley,fang]



//nurbs_interp_surface(blob1, 3, splinesteps=32, method=method, col_wrap=true,data_size=0);




mpts = [[5,0],[0,20],[33,43],[37,88],[60,62],[44,22],[77,44],[79,22],[44,3],[22,7]];
   knots = [0,1,3,5,9,13,13.5,14,19,21,24];
   e = nurbs_elevate_degree(mpts,2,knots=knots,times=2,type="closed");
   c1 = nurbs_curve(mpts,2,knots=knots,splinesteps=16,type="closed");
   c2 = nurbs_curve(e,splinesteps=16);
   echo(approx(c1,c2));
/* */
