include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//

type    = "closed";      // [clamped, closed]
method1 = "centripetal"; // [length,centripetal,dynamic,foley,fang]
method2 = "fang";        // [length,centripetal,dynamic,foley,fang]
color1  = "dodgerblue";
color2  = "cyan";
color = ["black", "brown", "red", "orange", "yellow", "green", "blue", "violet", "grey", "white"];

/* [Hidden] */
$vpt = [0,0,0];
$vpr = [0,0,0];
$vpd = 750;


//data = random_polygon(8, [100,100]);

data = regular_ngon(8, 100);


deriv = [[-.01,-1], undef, undef, undef, undef, undef, undef, undef];
curve = [1, undef, undef, undef, undef, undef, undef, undef];

debug_nurbs_interp(data,3, deriv = deriv, curvature = curve, splinesteps=32, type = "closed", show_ctrl=false, color=color1, data_color="red",  method=method1);
debug_nurbs_interp(data,3, deriv = deriv, curvature = curve, splinesteps=32, type = "closed", show_ctrl=false, color=color2, data_color="red",  method=method2);

for (i = [0:len(data)-1]) { move(data[i]) color(color[i]) sphere(r=2);}



echo(data);
color(color1) text3d(method1, size = 6, anchor = CENTER);
fwd(10)
color(color2) text3d(method2, size = 6, anchor = CENTER);
