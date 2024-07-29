
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>
include<BOSL2/rounding.scad>

$fn = 72;

bez = [[40,0], [110,40], [-60,50], [45,80]];

bez2 = bezpath_offset([5,0], bez);
closed= bezpath_curve(bez2, splinesteps = 32);
color("blue") stroke(closed);

path2 = bezier_curve(bez, splinesteps = 32);
closed2 = concat(path2,reverse(offset(path2,delta=5)),[bez[0]]);
right(30) color("red") stroke(closed2);

path = bezier_curve(bez, splinesteps = 32);
path3 = offset_stroke(path, [0,-2.5], start=os_flat(abs_angle=0), end=os_flat(abs_angle=0));
right(60) color("green") up(2.5) stroke(path3, closed = true);
*back_half(s = 200) rotate_sweep(path3,360);