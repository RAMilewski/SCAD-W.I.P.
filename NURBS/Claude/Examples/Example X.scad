
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
include <data.scad>


method="centripetal";   // [length,centripetal,dynamic,foley,quadratic]


//debug_nurbs_interp_surface(data1, 3, splinesteps=32, method=method, type=["clamped","closed"],data_size=0,
//      normal2=3*UP+RIGHT,u_edges=5,normal1=DOWN+LEFT/4);  





debug_nurbs_interp_surface(data2, 3, method = method, splinesteps=32);
/**/