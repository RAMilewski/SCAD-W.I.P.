include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>


pt=16;
//rainbow([1,1.02,1.04])
//xcopies(spacing=260,n=8)
  grid2d(n=[4,pt/4], spacing=260)
{
data = regular_ngon(pt,100);
d = [for(i=[0:pt-1]) i==$idx ? zrot(-360/pt*$idx,[0,-1.2,0]) : undef];
a=nurbs_interp(data,3,type="closed",method="centripetal",
   //                deriv=[DOWN*.8,undef,undef,undef,undef,undef,undef,undef]);
   //                deriv=[undef,undef,LEFT*.8,undef,undef,undef,undef,undef]);
   //                deriv=[undef,undef,undef,undef,UP,undef,undef,undef]);
               deriv=d);
echo(len(a[2]));
 echo(dd=d[$idx]);
intersection(){
  stroke(nurbs_curve(a,splinesteps=16),width=3);
  rect(250);
  }
  stroke(rect(250),closed=true,width=3/2,color="black");
  stroke([data[$idx],data[$idx]+d[$idx]*50], endcap2="arrow2",color="red",width=3);
}

$vpt = ([0,0,0]);
$vpr = ([0,0,0]);
$vpd = 3000;