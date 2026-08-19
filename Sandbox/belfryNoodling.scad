include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>



pts = [[0,0],[5,5],[10,8], [13,5],[16,0]];
pts2 = [[0,0],[5,5],[10,8], [13,5],[16,0],[16,-3],[14,-5],[8,-9],[4,-6],[0,0]];

c = nurbs_interp(pts2,3,corners=[2]);
//c = nurbs_interp(pts2,3,corners=[2],closed=true);

stroke(nurbs_curve(c),width=.2);
stroke(nurbs_curve(c),width=.2);

data = nurbs_curve(c,deriv=[0,1],two_sided=true);

for(d=data[1]) echo(d);

for(i=idx(data[0])){
  if (len(data[1][i])==2)
    for(k=data[1][i]) stroke( move(data[0][i], [[0,0],k/3]),endcap2="arrow2",width=.1, color="purple");
  }
