include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>

$vpt = [0,0,0];
$vpr = [0,0,0];
$vpd = 750;


data = [[0,0], [20,30], [30,90], [36,111],[50,25], [80,0]]; 

color("red") move_copies(data) sphere(r=2, $fn=16);

path =  nurbs_interp_curve (data, 3, param="centripetal", type = "closed", splinesteps=32);
color("yellow") path_sweep (circle(d = 1),path);

path2 = nurbs_interp_curve (data, 3, param="length",      type = "closed", splinesteps=32);
color("green") path_sweep (circle(d = 1),path2);

path3 = nurbs_interp_curve (data, 3, param="dynamic",     type = "closed", splinesteps=32);
color("blue") path_sweep (circle(d = 1),path3);