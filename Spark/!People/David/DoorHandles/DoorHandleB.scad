include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

$fn = 72;

span = 112;
loft = 50;
bolt = 6.5;

data = [[-span/2,0,0],[-span/2,0,10],[-55,0,80],[0,0,85],[55,0,80],[span/2,0,10],[span/2,0,0]];
path = nurbs_curve(nurbs_interp(data,3, deriv = [UP*1.5,UP,undef,RIGHT,undef,DOWN,DOWN*1.5]));

diff() {
    back(15) xcopies(n = 2, spacing = span) {
        cuboid([20,50,12], chamfer = 3, except = [BOT])
            position(TOP) wedge([14,14,24], anchor = BOT);
        back(15)tag("remove") cyl(h = 15.1, d = bolt);
    }
}
path_sweep(rect([20,20], chamfer = 3), path);