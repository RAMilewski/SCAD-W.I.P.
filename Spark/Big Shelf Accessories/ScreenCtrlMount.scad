include <BOSL2/std.scad>

$fn = 72;

rect = [21,37,0.8];
gap = [rect.x + 10, 26];
post = [6,undef,5];
cap = [12,undef,3];


xcopies(gap.x, n = 2) cuboid(rect, rounding = rect.z, edges = TOP);
cuboid([15,gap.y,rect.z], rounding = rect.z, edges = TOP); 
xcopies(38,2) cyl(post.z, d = post.x, anchor = BOT)
    position(TOP) cyl(cap.z, d = cap.x, rounding = 1, anchor = BOT);
    