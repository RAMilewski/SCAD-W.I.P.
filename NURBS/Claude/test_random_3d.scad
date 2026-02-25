include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
$vpt = [0,0,0];

type = "closed"; // [closed,clamped,open]

closed_stroke =  (type == "closed");
   
data3d = random_points(12,3,[20,20,20]);
echo(data3d);
path = nurbs_interp_curve(data3d, 3, splinesteps=32, type=type);
stroke(path, closed = closed_stroke, width=.2);
color("red") move_copies(data3d) sphere(r=.5, $fn=16);
