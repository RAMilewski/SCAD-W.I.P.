
include<BOSL2/std.scad>
include<BOSL2/beziers.scad>


bezpath = flatten([
    bez_begin([-50,  0],  45,20),
    bez_tang ([  0,  0],-135,20),
    bez_joint([ 20,-25], 135, 90, 10, 15),
    bez_end  ([ 50,  0], -90,20),
]);
debug_bezier(bezpath);
