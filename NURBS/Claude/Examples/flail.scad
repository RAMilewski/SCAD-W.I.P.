include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
//include <data.scad>
include <../nurbs_interp.scad>


$vpr = [0,0,0];
$vpt = [0,0,0];

data2 = [[54.2713, -14.679], [41.5689, -29.042], [67.9256, -63.3349], [-50.39, -73.0243], [-36.9592, -43.2663], [-34.3756, -26.604], [-50.5462, -22.6036], [-42.484, 12.7769], [-53.767, 57.6077], [-4.56084, 49.3793], [3.27214, 28.315]];


a=nurbs_interp(data2,3, type="closed",extra_pts=3,smooth=3,
                     deriv=[[-.2,-1]/2, [-.5,-1]/2, [-1,-1.2], [-1,1.5]/4, each repeat(undef,4),(RIGHT+UP*1)/2,undef,DOWN],
                     curvature=[-1/8 /*[-1/80,0]*/,each repeat(undef,10)]);
b=nurbs_interp(data2,3, type="closed",extra_pts=4,smooth=3,
                     deriv=[[-.2,-1]/2, [-.5,-1]/2, [-1,-1.2], [-1,1.5]/4, each repeat(undef,4),(RIGHT+UP*1)/2,undef,DOWN],
                     curvature=[-1/8 /*[-1/80,0]*/,each repeat(undef,10)]);
echo(len(a[2]));
echo(len(b[2]));
