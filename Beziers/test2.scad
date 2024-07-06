
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bezpath = flatten([
    bez_begin([0,0], 90, 5),
    bez_joint([0,9], -90, 0, 10,10),
    bez_joint([5,9], 180, 70, 9,20),
    bez_tang([80,65], 3, 35, 20),
    bez_joint([130,60], 160, -60, 10, 30),
    bez_joint([140,42], 120, 0, 20,55),
    bez_joint([208,9], 90, 0, 10,6),
    bez_joint([214,9], 180, -90, 10,10),
    bez_joint([214,0], 90, 180, 10,10),
    bez_joint([189,0], 0, -100, 10,10),
    bez_tang([170,-17], 180, 10),
    bez_joint([152,0], -85, 180, 10,10),
    bez_joint([52,0], 0, -100, 10,10),
    bez_tang([33,-17], 180, 10),
    bez_joint([16,0], -85,180, 10,10),
    bez_end  ([0,0], 0,20)
]);

path = bezpath_curve(bezpath, splinesteps = 32); 
stroke(path);

//linear_sweep(path_merge_collinear(path, closed = true),h = 20);

sq = square(1);
path_sweep(sq,path_merge_collinear(path, closed = true)); 