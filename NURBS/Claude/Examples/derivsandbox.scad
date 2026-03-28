include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
include <data.scad>
include <BOSL2/fnliterals.scad>
include <center_viewport.scad>
//


type    = "clamped";      // [clamped, closed]
method1 = "centripetal"; // [length,centripetal,dynamic,foley,fang]
method2 = "fang";        // [length,centripetal,dynamic,foley,fang]
color1  = "dodgerblue";
color2  = "cyan";
degree = 3;             // [2:1:7]
color = ["black", "sienna", "red", "darkorange", "yellow", "limegreen", "deepskyblue", "darkviolet", "grey", "white"];


data = [[0,0], [0,9], [5,9], [80,65], [130,60], [140,42], [208,9], [214,9], 
        [214,0], [189,0], [170,-17], [152,0], [52,0], [33,-17], [16,0],[0,0]];


proto_deriv = [undef, undef, undef, RIGHT, RIGHT, RIGHT+DOWN, undef, undef, 
                RIGHT, LEFT, undef, RIGHT, RIGHT, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef];

deriv = slice(proto_deriv, 0, len(data)-1);

proto_curve = [undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef];

curve = slice(proto_curve, 0, len(data)-1);



debug_nurbs_interp(data,degree, type = type, deriv = deriv, curvature = curve, splinesteps=32, show_ctrl=false, color=color1, data_color="red",  method=method1);
debug_nurbs_interp(data,degree, type = type, deriv = deriv, curvature = curve, splinesteps=32, show_ctrl=false, color=color2, data_color="red",  method=method2);

for (i = [0:len(data)-1]) { move(data[i]) color(color[i%10]) sphere(r=2);}



echo(data);
color(color1) text3d(method1, size = 6, anchor = CENTER);
fwd(10)
color(color2) text3d(method2, size = 6, anchor = CENTER);





$vpt = point3d(centroid(data));
$vpr = [0,0,0];
$vpd = camera_distance(data);



