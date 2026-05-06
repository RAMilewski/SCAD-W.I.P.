include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>


data1 = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]];

method="length";   // [length,centripetal,dynamic,foley]


debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed",
                        deriv=[undef,undef,undef,undef,[1,-1]/2,LEFT/3],
                        curvature=[undef,undef,undef,undef,undef,undef]
       );