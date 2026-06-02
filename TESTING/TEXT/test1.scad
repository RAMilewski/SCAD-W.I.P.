include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
data = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]];
xdistribute(100){
   union(){
       debug_nurbs_interp(data,3, splinesteps=32, data_size=1);
       fwd(15)text("unconstrained",size=6);
   }
   union(){
       debug_nurbs_interp(data,3, splinesteps=32, data_size=1,
                     start_deriv=RIGHT);
       fwd(15)text("start=RIGHT",size=6);
   }
   union(){
       debug_nurbs_interp(data,3, splinesteps=32, data_size=1,
                   start_deriv=2*RIGHT,end_deriv=RIGHT);
       fwd(15)text("start=[2,0] end=[1,0]",size=6);
   }
}