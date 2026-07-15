include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

$fn = 72;
span = 112;
loft = 50;
bolt = 6.4;

data = [[-span/2+1,0,0],[-52,0,50],[0,0,55],[52,0,50],[span/2-1,0,0]];

path = nurbs_curve(nurbs_interp(data,3, deriv = [UP*2,undef,RIGHT,undef,DOWN*2]));

diff() {
back(9) xflip_copy(offset = span/2) 
    cuboid([22,38,8], chamfer = 3, except = [BOT], anchor = BOT)
    back(10)tag("remove") cuboid([bolt,bolt,8.1]);
}
path_sweep(rect([15,20], chamfer = 3), path);
