include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<nurbs_interp.scad>

data1 = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]];

method="centripetal";

xdistribute(100){
 union(){
    debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method);
    fwd(15)text("unconstrained",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        start_deriv=RIGHT);
    fwd(15)text("start=RIGHT",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        start_deriv=2*RIGHT,end_deriv=RIGHT);
    fwd(15)text("start=[2,0] end=[1,0]",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        start_deriv=2*RIGHT,end_deriv=RIGHT, start_curvature=0 //curvature=[undef,0,undef,undef,undef,undef]
       );
    fwd(15)text("start=[2,0] end=[1,0]",size=6);
 }
}
