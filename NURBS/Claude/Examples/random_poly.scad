include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <../nurbs_interp.scad>
//

method1="centripetal";   // [length,centripetal,dynamic,foley,fang]
method2="fang";   // [length,centripetal,dynamic,foley,fang]
color1 = "dodgerblue";
color2 = "cyan";

/* [Hidden] */
$vpt = [0,0,0];
$vpr = [0,0,0];
$vpd = 750;

//data = random_polygon(n = 8, angle_sep=0, size = [80,100]);
//data = [[84.3846, -1.04655], [73.2439, -44.7969], [62.3447, -71.7714], [56.7171, -69.4369], [-54.6133, -76.949], [-85.0447, -23.6256], [-78.0719, 60.0387], [-22.3284, 83.7666]];

data = regular_ngon(8, 50);


deriv = [undef, [-.1,0], undef, undef, undef, undef, undef, undef];



debug_nurbs_interp(data,3, deriv = deriv, splinesteps=32, type = "closed", show_ctrl=false, color=color1, data_color="red",  method=method1);
//debug_nurbs_interp(data,3, splinesteps=32, type = "closed", show_ctrl=false, color=color2, data_color="red", data_size=1, method=method2);
//stroke(data, closed = true, width = 0.5);
echo(data);
color(color1) text3d(method1, size = 6, anchor = CENTER);
fwd(10)
color(color2) text3d(method2, size = 6, anchor = CENTER);
