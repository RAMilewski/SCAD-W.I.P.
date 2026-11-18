include <BOSL2/std.scad>

$fn = 72;

rect = [21,38.5,2];
gap = [rect.x + 10, 26];


xcopies(gap.x, n = 2) cuboid(rect, rounding = 2, edges = TOP);
cuboid([15,gap.y,2], rounding = 1, edges = TOP); 