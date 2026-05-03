include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>


data1 = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]];

method="length";   // [length,centripetal,dynamic,foley]


xdistribute(100){
 union(){
    debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method);
    fwd(15)text("unconstrained",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method,
                        start_deriv=RIGHT);
    fwd(15)text("start=RIGHT",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method,
                        start_deriv=2*RIGHT,end_deriv=RIGHT);
    fwd(15)text("start=[2,0] end=[1,0]",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method,
                        deriv=[2*RIGHT,[0,1],undef,undef,undef,RIGHT],
       );
    fwd(15)text("derivs at 0, 1, 5",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method,
                        deriv=[undef,[0,1],undef,undef,RIGHT,undef],
       );
    fwd(15)text("derivs at pts 1, 4",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method,
                        deriv=[undef,[0,1],undef,undef,NAN,undef],
       );
    fwd(15)text("corner and pt 1 deriv",size=6);
 }
}




fwd(150)
xdistribute(100){
 union(){
    debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method, closed = true);
    fwd(22)text("unconstrained",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method, closed = true,
                        deriv=[[0,1]/4, undef, undef, undef, undef, [0,-1]/3],
       );
    fwd(22)text("derivs 0, 5",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method, closed = true,
                        deriv=[undef,undef,undef,[1,0],undef,undef],
       );
    fwd(22)text("derivs at pts 4",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method, closed = true,
                        deriv=[undef,[0,1],undef,undef,NAN,undef],
       );
    fwd(22)text("corner and pt 1 deriv",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, method=method, closed = true,
                        deriv=[undef,NAN,undef,undef,NAN,undef],
       );
    fwd(22)text("2 corners",size=6);
 }
}
