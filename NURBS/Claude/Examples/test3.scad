include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//
$vpt = [0,0,0];
$vpr = [0,0,0];

data = [[0.00,0.00], [0.10,0.90], [0.20,0.95], [0.30,0.90], [0.40,0.10], 
        [0.50,0.05], [0.60,0.05], [0.80,0.20], [1.00,1.00]];


path = nurbs_interp_curve (data, 3,  method="centripetal", splinesteps=32);
path2 = nurbs_interp_curve (data, 3, method="dynamic", splinesteps=32);
path3 = nurbs_interp_curve (data, 3, method="length", splinesteps=32);

color("yellow") path_sweep (circle(d = .02),path);
color("blue") path_sweep (circle(d = .02),path2);
color("green") path_sweep (circle(d = .02),path3);
color("red") move_copies(data) sphere(r=0.03, $fn=16);