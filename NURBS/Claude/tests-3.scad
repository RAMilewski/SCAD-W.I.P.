include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<nurbs_interp.scad>


method="centripetal";   // [length,centripetal,dynamic,foley]



data1 = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]];

data2 = [[54.2713, -14.679], [41.5689, -29.042], [67.9256, -63.3349], [-50.39, -73.0243], [-36.9592, -43.2663], [-34.3756, -26.604], [-50.5462, -22.6036], [-42.484, 12.7769], [-53.767, 57.6077], [-4.56084, 49.3793], [3.27214, 28.315]];


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
                        deriv=[2*RIGHT,[0,1],undef,undef,undef,RIGHT],
       );
    fwd(15)text("derivs at 0, 1, 5",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        deriv=[undef,[0,1],undef,undef,RIGHT,undef],
       );
    fwd(15)text("derivs at pts 1, 4",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        deriv=[undef,[0,1],undef,undef,NAN,undef],
       );
    fwd(15)text("corner and pt 1 deriv",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        start_deriv=2*RIGHT,end_deriv=RIGHT, start_curvature=0,end_curvature=0);
    fwd(15)text("ends curvature=0",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black",  method=method,
                        start_deriv=RIGHT,end_deriv=RIGHT, start_curvature=1/10*unit([1000,1]),end_curvature=1/5);
     stroke(arc(angle=[180,270], cp=[0,10],r=10));
     stroke(arc(angle=[270,360], cp=last(data1)+[0,5], r=5,$fn=32));
    fwd(15)text("ends curvature>0",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
                        deriv=[undef,[0,1],undef,[1,0],undef,undef],
                        curvature=[undef,-1/10,undef,0,undef,undef]
       );
    fwd(15)text("curvature at pts 1 and 3", size=6);
 }
}




fwd(150)
xdistribute(100){
 union(){
    debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed");
    fwd(22)text("unconstrained",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed",
                        deriv=[[0,1]/4, undef, undef, undef, undef, [0,-1]/3],
       );
    fwd(22)text("derivs 0, 5",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed",
                        deriv=[undef,undef,undef,[1,0],undef,undef],
       );
    fwd(22)text("derivs at pts 4",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed",
                        deriv=[undef,[0,1],undef,undef,NAN,undef],
       );
    fwd(22)text("corner and pt 1 deriv",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed",
                        deriv=[undef,NAN,undef,undef,NAN,undef],
       );
    fwd(22)text("2 corners",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method, type="closed",
                        deriv=[undef,undef,undef,undef,[1,-1]/2,LEFT/3],
                        curvature=[undef,undef,undef,undef,undef,undef]
       );
    fwd(22)text("2 corners",size=6);
 }
}


fwd(300)
xdistribute(135){
 union(){
    debug_nurbs_interp(data2,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method);
    left(40)fwd(95)text("unconstrained deg 3",size=6);
 }
 union(){
    debug_nurbs_interp(data2,4, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method);
    left(40)fwd(95)text("unc. deg 4",size=6);
 }
 union(){
    debug_nurbs_interp(data2,5, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method);
    left(40)fwd(95)text("unc. deg 5",size=6);
 }
 union(){
    debug_nurbs_interp(data2,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
      corners=[3,7]
      );
    left(40)fwd(95)text("2 corners, deg 3",size=6);
 }
 union(){
    debug_nurbs_interp(data2,4, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
      corners=[6]
      );
    left(40)fwd(95)text("1 corners, deg 4",size=6);
 }
 union(){
    debug_nurbs_interp(data2,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,
      deriv=[undef,undef,[-1,-.2],undef,[.3,1]/1.5,NAN,undef,undef,undef,undef,undef],
      curvature=[undef,undef,0,undef,undef,undef,undef,undef,undef,undef,undef],
                        
      );
    left(40)fwd(95)text("1 corner, 2 deriv, 1 curv deg 3",size=6);
 }
}



fwd(476)
xdistribute(135){
 union(){
    debug_nurbs_interp(data2,3, splinesteps=32, show_ctrl=false, data_color="black", data_size=1, method=method,type="closed");
    left(40)fwd(95)text("unconstrained deg 3",size=6);
 }
}
/**/
