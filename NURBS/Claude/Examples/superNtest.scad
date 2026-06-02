include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>
include<data.scad>



$vpt=[0,-223.9,0];
$vpr=[0,0,0];
$vpd=2034.0;



xdistribute(100){
 union(){
    debug_nurbs_interp(data1,3, splinesteps=32, data_size=1);
    fwd(15)text("unconstrained",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        start_deriv=RIGHT);
    fwd(15)text("start=RIGHT",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        start_deriv=2*RIGHT,end_deriv=RIGHT);
    fwd(15)text("start=[2,0] end=[1,0]",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        deriv=[2*RIGHT,[0,1],undef,undef,undef,RIGHT],
       );
    fwd(15)text("derivs at 0, 1, 5",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        deriv=[undef,[0,1],undef,undef,RIGHT,undef],
       );
    fwd(15)text("derivs at pts 1, 4",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        deriv=[undef,[0,1],undef,undef,NAN,undef],
       );
    fwd(15)text("corner and pt 1 deriv",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        start_deriv=2*RIGHT,end_deriv=RIGHT, start_curvature=0,end_curvature=0);
    fwd(15)text("ends curvature=0",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32,
                        start_deriv=RIGHT,end_deriv=RIGHT, start_curvature=1/10*unit([1000,1]),end_curvature=1/5);
    color("red") stroke(arc(angle=[180,270], cp=[0,10],r=10));
    color("red") stroke(arc(angle=[270,360], cp=last(data1)+[0,5], r=5,$fn=32));
    fwd(15)text("ends curvature>0",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1,
                        deriv=[undef,[0,1],undef,[1,0],undef,undef],
                        curvature=[undef,-1/10,undef,0,undef,undef]
       );
    fwd(15)text("curvature at pts 1 and 3", size=6);
 }
}




fwd(150)
xdistribute(100){
 union(){
    debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, closed=true);
    fwd(22)text("unconstrained",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, closed=true,
                        deriv=[[0,1]/4, undef, undef, undef, undef, [0,-1]/3],
       );
    fwd(22)text("derivs 0, 5",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, closed=true,
                        deriv=[undef,undef,undef,[1,0],undef,undef],
       );
    fwd(22)text("derivs at pts 4",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, closed=true,
                        deriv=[undef,[0,1],undef,undef,NAN,undef],
       );
    fwd(22)text("corner and pt 1 deriv",size=6);
 }
 union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, closed=true,
                        deriv=[undef,NAN,undef,undef,NAN,undef],
       );
    fwd(22)text("2 corners",size=6);
 }
 *union(){
     debug_nurbs_interp(data1,3, splinesteps=32, data_size=1, closed=true,
                       deriv=[undef,undef,undef,undef,[1,-2]/2,undef],//LEFT/3],
//                        deriv=[undef,[0,1/2]/4,undef,undef,undef, [1.5,-1]/4, [0,-1]/2],
                        curvature=[undef,undef, 1/20,undef,undef,undef]
       );
    fwd(22)text("",size=6);
 }
}