
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bezpath = flatten([
    bez_begin([0,0], BACK, 15),
    bez_joint([0,9], FWD, RIGHT, 10,10),
    bez_joint([5,9], LEFT, 70, 9,20),
    bez_tang([80,65], 3, 35, 20),
    bez_joint([130,60], 160, -60, 10, 30),
    bez_joint([140,42], 120, 0, 20,55),
    bez_joint([208,9], BACK, RIGHT, 10,6),
    bez_joint([214,9], LEFT, FWD, 10,10),
    bez_joint([214,0], BACK, LEFT, 10,10),
    bez_joint([189,0], RIGHT, -95, 10,10),
    bez_tang([170,-17], LEFT, 10),
    bez_joint([152,0], -85, LEFT, 10,10),
    bez_joint([52,0], RIGHT, -95, 10,10),
    bez_tang([33,-17], LEFT, 10),
    bez_joint([16,0], -85,LEFT, 10,10),
    bez_end  ([0,0], RIGHT,10)
]);

path = bezpath_curve(bezpath, splinesteps = 32); 
stroke(path);
//debug_bezier(bezpath);



//linear_sweep(path_merge_collinear(path, closed = true),h = 20);

//sq = square(1);
//path_sweep(sq,path_merge_collinear(path, closed = true)); 