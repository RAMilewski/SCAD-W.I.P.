
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

bezpath = flatten([
    bez_begin([0,0], 0,0),
    bez_joint([0,9], -90, 0, 10,10),
    bez_joint([5,9], 180, 70, 9, 20),
    bez_tang([80,65], 3, 35, 20),
    bez_joint([130,60], 160, -60, 10, 30),
    bez_joint([140,42], 120, 0, 20,55),
    bez_joint([208,9], 90, 0, 10,10),
    bez_joint([214,9], 180, -90, 10,10),
    bez_joint([214,0], 90, 180, 10,10),
    bez_joint([189,0], 0, -90, 10,10),
    bez_tang([170,-17], 180, 10),
    bez_joint([152,0], -90, 180, 10,10),
    bez_joint([52,0], 0, -90, 10,10),
    bez_tang([33,-17], 180, 10),
    bez_joint([16,0], -90,180, 10,10),
    bez_end  ([0,0], 0,20)
]);


sq = square(6, center = true);
path = path_merge_collinear(bezpath_curve(bezpath), closed = true);


//color("blue") stroke(path,width = 1, closed = true);

inside = offset(path, delta = -5, closed = true);
outside = offset(path, r = 5, closed = true);
blade = offset(path, delta = -1.5, closed = true);
//stroke(inside, closed = true);
//stroke(outside, closed = true);


difference() {
    linear_sweep(outside, h = 5);
    linear_sweep(inside, h = 5);
}

difference() {
    linear_sweep(path, h = 25);
    linear_sweep(blade, h = 25);
}



/*
color("blue") stroke(bezpath_curve(bezpath), width = 6);
color("red") stroke(bezpath_curve(bezpath), width = 2);



/* */