include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
$vpt = [0,0,0];

type = "closed"; // [closed,clamped]
count = 8;     // [4:1:25]

closed_stroke =  (type == "closed");
   
data3d = random_points(count,3,[20,20,20]);
echo(data3d);

color("red") move_copies(data3d) sphere(r=.5, $fn=16);

path = nurbs_interp_curve(data3d, 3, splinesteps=32, method="centripetal", type=type);
color("dodgerblue") stroke(path, closed = closed_stroke, width=.2);

path2 = nurbs_interp_curve(data3d, 3, splinesteps=32, method="lockyer", type=type);
color("green") stroke(path2, closed = closed_stroke, width=.2);

/* */
