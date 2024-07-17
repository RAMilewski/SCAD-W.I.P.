include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 72;


toppath = flatten([
    bez_begin([-50,0,20],  BACK, 27.625),
    bez_joint([0,50,30],  LEFT+UP, RIGHT+UP, 27.625,27.625),
    bez_tang ([50,0,20],   FWD, 27.625),
    bez_joint([0,-50,30], RIGHT+DOWN, LEFT+DOWN, 27.625,27.625),
    bez_end  ([-50,0,20],  FWD, 27.625)
]);


top = bezpath_curve(toppath);

path_sweep(circle(1),top, closed = true);


