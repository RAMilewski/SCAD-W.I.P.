include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>

module shownurbs(curve,type="clamped",color=undef)
{
  c=nurbs_curve(curve[0],3,knots=curve[1], type=type, splinesteps=64);
  stroke(c, color=color, width=0.3*3,endcaps="arrow2");
color("green")  move(c[0]) circle(r=1.5);
}

function dnurbs(curve) =
  let(
      h=1e-8,
      val=nurbs_curve(curve[0], 3, knots=curve[1], u=[0,h,1-h,1])
  )
  [val[1]-val[0], val[3]-val[2]]/h;


data2 = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]];
len2 = path_length(data2);
data1 = [[0,0], [20,30], [50,25], [80,0]];
len1 = path_length(data1);


type="closed";
for(rot=[3:5]){
x=nurbs_interp(list_rotate(data2,rot), 3, type=type, derivs=list_rotate([undef,[0,len2],undef,undef,undef,[0,-len2]],rot),centripetal=true);
fwd(140*rot){shownurbs(x,type);
     color("red")move_copies(data2) circle(r=2);
}     
echo_nurbs(x,"x");

}
