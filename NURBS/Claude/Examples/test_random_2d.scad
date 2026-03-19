include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
$vpt = [0,0,0];
$vpr = [0,0,0];

type = "closed"; // [closed,clamped]
count = 8;     // [4:1:25]

closed_stroke =  (type == "closed");
   
data3d = random_points(count,2,[20,20]);

//data3d = [[69.5151, -50.0997], [66.0449, -60.5097], [52.7629, -76.2048], [29.6418, -85.5483], 
//        [26.6663, -94.3147], [12.1487, -93.6492], [-60.3779, -60.5089], [59.1532, 62.3245]];

echo(data3d);

color("red") move_copies(data3d) sphere(r=.5, $fn=16);

path = nurbs_interp_curve(data3d, 3, splinesteps=32, method="centripetal", type=type);
color("dodgerblue") stroke(path, closed = closed_stroke, width=.2);

path2 = nurbs_interp_curve(data3d, 3, splinesteps=32, method="lockyer", type=type);
color("gold") stroke(path2, closed = closed_stroke, width=.2);

path3 = smooth_path(data3d, splinesteps = 32);
color("limegreen") stroke(path3, closed = closed_stroke, width=.2);

/* */
