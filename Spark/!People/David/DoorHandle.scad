include<BOSL2/std.scad>
include<BOSL2/nurbs.scad>

$fn = 72;

span = 112;
loft = 50;
bolt_dia = 8;


data = [[-span/2,0,0],[-52,0,50],[0,0,55],[52,0,50],[span/2,0,0]];

path = nurbs_curve(nurbs_interp(data,3, deriv = [UP*1.5,undef,RIGHT,undef,DOWN*1.5]));


diff() {
    back(10) xflip_copy(offset = span/2) 
        cuboid([20,40,8], rounding = 3, except = [BOT], anchor = BOT)
           back(10)tag("remove")cyl(h = 8.1, d = bolt_dia);
}


path_sweep(rect([15,20], rounding = 3), path);

fwd(15) ycyl(2, 2);   // Force bed plate supports