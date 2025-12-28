include <BOSL2/std.scad>

eps = 0.01;
slop = 0.2;
$fa = 3;
$fs = 0.2;
inches = 25.4;

path = [for (theta = [180:5:360])
    [10 * cos(theta), 10 * sin(theta)],[10, 20]];
stroke(path);
two = [
    circle(d = 6),
    back(10, right(-3, square(6)))
    ];
stroke(two);
path_sweep(hull_region(two), path);