include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<BOSL2/rounding.scad>


r = 50;  // radius of the circle
n = 4;   //bezier segments to complete circle
d = r * (4/3) * tan(180/(2*n)); //control point distance

bez = flatten([
    bez_begin([-r,0],  90, d),
    bez_tang ([0,r],    0, d/2),
    bez_tang ([r,0],  -90, d),
    bez_tang ([0,-r], 180, d * 3),
    bez_end  ([-r,0], -90, d)
]);

path = bezpath_curve(bez);

stroke(path, closed = true);
//stroke(path, closed = true);
color("blue") stroke(offset(path, -5), closed = true);
/* */