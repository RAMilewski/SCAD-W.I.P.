include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>




data = [
    [0.00,  0.00], [1.34,  5.00], [5.00,  8.66], [10.00, 10.00], [10.60, 10.40], [10.70, 12.00],
    [10.70, 28.60], [10.80, 30.20], [11.40, 30.60], [19.60, 30.60], [20.20, 30.20], [20.30, 28.60], 
    [20.30, 12.00], [20.40, 10.40], [21.00, 10.00], [26.00,  8.66], [29.66,  5.00], [31.00,  0.00]
];

$vpt = [0,0,0];
$vpr = [0,0,0];
$vpd = 200;


color("red") move_copies(data) sphere(r=0.3, $fn=16);

path =  nurbs_interp_curve (data, 3, param="centripetal", type = "clamped", splinesteps=32);
color("yellow") path_sweep (circle(d = .25),path);

path2 = nurbs_interp_curve (data, 3, param="fang",     type = "clamped", splinesteps=32);
color("skyblue") path_sweep (circle(d = .25),path2);

/*
path3 = nurbs_interp_curve (data, 3, param="length",      type = "clamped", splinesteps=32);
color("green") path_sweep (circle(d = .25),path3);


path4 = nurbs_interp_curve (data, 3, param="dynamic",     type = "clamped", splinesteps=32);
color("black") path_sweep (circle(d = .25),path4);

*/
path5 = nurbs_interp_curve (data, 3, param="foley",     type = "clamped", splinesteps=32);
color("fuchsia") path_sweep (circle(d = .25),path5);

/**/
