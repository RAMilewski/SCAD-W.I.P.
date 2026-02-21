// ---- Example 4: Closed polygon ----
//
include <BOSL2/std.scad>
include <BOSL2/nurbs.scad>
include <nurbs_interp.scad>
//
data = [[0,0], [30,50], [60,40], [80,10], [50,-20], [20,-10]];

result  = nurbs_interp(data, 3, type="clamped");
control = result[0];
knots   = result[1];

echo("data ",data);
echo("knots ",knots);
echo("control ",control);

path = nurbs_interp_curve(data, 3, splinesteps=1, type="clamped");
polygon(path);

color("red") move_copies(data) circle(r=0.5, $fn=16);