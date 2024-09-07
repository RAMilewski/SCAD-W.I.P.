include <BOSL2/std.scad>
include <BOSL2/beziers.scad>

patch = [
    [[-50, 50,  0], [-16, 50,  20], [ 16, 50,  20], [50, 50,  0]],
    [[-50, 16, 20], [-16, 16,  40], [ 16, 16,  40], [50, 16, 20]],
    [[-50,-16, 20], [-16,-16,  40], [ 16,-16,  40], [50,-16, 20]],
    [[-50,-50,  0], [-16,-50,  20], [ 16,-50,  20], [50,-50,  0]]
];

for (row = [0:3]) {
    bez = patch[row];
    color("blue") stroke(bezpath_curve(bez));
}

for (col = [0:3]) {
    bez2 = [patch[0][col], patch[1][col], patch[2][col], patch[3][col]];
    color("green") stroke(bezpath_curve(bez2));
}

vnf_polyhedron(bezier_vnf(patch));


