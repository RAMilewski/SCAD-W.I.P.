include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>


count   = 5;
type    = "closed";      // [clamped, closed]
method1 = "centripetal"; // [length,centripetal,dynamic,foley,fang]
method2 = "fang";        // [length,centripetal,dynamic,foley,fang]
color1  = "dodgerblue";
color2  = "cyan";
degree = 3;              // [2:1:7]

color = ["black", "sienna", "red", "darkorange", "yellow", "limegreen", "deepskyblue", "darkviolet", "grey", "white"];


/* [Hidden] */
$vpt = [0,0,0];
$vpr = [0,0,0];
$vpd = 750;


data = regular_ngon(count, 100);

proto_deriv = [DOWN*1.2, undef, undef, UP, undef, undef, undef, undef, 
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef];

deriv = slice(proto_deriv, 0, count-1);

proto_curve = [undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef,
                undef, undef, undef, undef, undef, undef, undef, undef];

curve = slice(proto_curve, 0, count-1);



debug_nurbs_interp(data,degree, type = type, deriv = deriv, curvature = curve, splinesteps=32, show_ctrl=false, color=color1, data_color="red",  method=method1);
debug_nurbs_interp(data,degree, type = type, deriv = deriv, curvature = curve, splinesteps=32, show_ctrl=false, color=color2, data_color="red",  method=method2);


for (i = [0:len(data)-1]) { move(data[i]) color(color[i%10]) sphere(r=3);}



echo(data);
color(color1) text3d(method1, size = 6, anchor = CENTER);
fwd(10)
color(color2) text3d(method2, size = 6, anchor = CENTER);
