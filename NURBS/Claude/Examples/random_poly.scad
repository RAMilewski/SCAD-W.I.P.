include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
$vpt = [0,0,0];

data = random_polygon(n = 8, angle_sep=0, size = [80,100]);
color("dodgerblue")debug_nurbs_interp(data,3, splinesteps=32, type = "closed", show_ctrl=false, data_color="black", data_size=1, method="lockyer");
color("yellow")debug_nurbs_interp(data,3, splinesteps=32, type = "closed", show_ctrl=false, data_color="black", data_size=1, method="centripetal");
color("green") stroke(data, closed = true, width = 0.5);
echo(data);
