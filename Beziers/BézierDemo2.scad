include <BOSL2/std.scad>
include <BOSL2/beziers.scad>
$fn = 6;
bez = [[15,0], [45,20], [-10,55], [25,90]];

offset = [2,0];
bez2 = bezpath_offset(offset, bez);
path = bezpath_curve(bez2, splinesteps = 64);
rotate_sweep(path,360);
floor = 2;
 u = bezier_line_intersection(bez,[[0,floor],[1,floor]]);
cyl(r1 = bez[0].x, r2 = bezier_points(bez,u)[0].x, h = floor, anchor = BOT);










/*** Ignore everything below this line.  Here there be dragons.

bez = [[15,0], [0,10], [10,40], [15,60]];
bez = [[60,0], [70,10], [80,20], [70,30]];
bez = [[20,0], [50,50], [-20,50], [20,100]];
bez = [[10,0], [70,30], [15,50], [40,100]];
bez = [[50,0], [55,30], [15,60], [30,120]];
bez = [[15,0], [45,50], [-10,55], [15,70]];

*/