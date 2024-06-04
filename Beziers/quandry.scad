include <BOSL2/std.scad>
include <BOSL2/beziers.scad>

bez = [[10,0], [20,10], [0,20], [10,30]];
debug_bezier(bez);

line = [[0,5],[20,5]];
stroke(line);

u = bezier_line_intersection(bez, line);
echo(u);   // returns [0.166667]
pt = bezier_points(bez,u);
echo(pt);  // returns []