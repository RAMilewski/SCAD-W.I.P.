include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 72;

r = 10;  // radius of the circle
n = 4;   //bezier segments to complete circle
d1 = r * (4/3) * tan(180/(2*n)); //control point distance

bez = flatten([
    bez_begin([10,0], 90, 6),
    bez_tang([3.5,6], 60, 3, 3),
    bez_tang([7.5,10], 45, 2, 2),
    bez_joint([10,20], -90, 180, 5, 5),
    bez_joint([9.5,20], 0, -90, 5, 2),
    //bez_joint([3.5,8], -90, 0, 5, 5),
    bez_end([0,16], 0, 2)
]);


path = bezpath_curve(bezpath_close_to_axis(bez,"Y"));

rotate_sweep(path);
up(15.75) cyl(d1 = 2.75, d2 = 1, h = 5, anchor = BOT);