include <BOSL2/std.scad>
path = circle(d=100,$fn=3);
pt = [20,10];
closest = path_closest_point(path, pt);
stroke(path, closed=true);
color("blue") translate(pt) circle(d=3, $fn=12);
color("red") translate(closest[1]) circle(d=3, $fn=12);

