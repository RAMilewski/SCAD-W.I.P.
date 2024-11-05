include<BOSL2/std.scad>
include<BOSL2/beziers.scad>

$fn = 72;
core = 7.5;
cup = [23,20,35]; //[d,undef,h]


 bezpath = flatten ([
        bez_begin([core,0], 85, cup.z/4),
        bez_tang([cup.x/2,cup.z/2.5], 90, cup.z/8),
        bez_joint([cup.y/2,cup.z], -86, 180, 10, 10),
        bez_joint([cup.y/2 - 1, cup.z], 0, -93, 10, 20),
        bez_end([0,cup.z/2], 0, cup.x/4),
        
    ]);

    debug_bezier(bezpath, width = .1);