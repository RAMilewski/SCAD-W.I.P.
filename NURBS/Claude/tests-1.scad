include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>



// Example(3D): 3D closed curve
   data3d = [[20,0,0],[0,20,20],[-20,0,0],[0,-20,10]];
   debug_nurbs_interp(data3d, 3, splinesteps=32, closed=true);
   
