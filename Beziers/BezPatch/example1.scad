include <BOSL2/std.scad>
include <BOSL2/beziers.scad>

patch = [
    // u=0,v=0                                         u=1,v=0
    [[-50,-50, 0], [-16,-50,  0], [ 16,-50, 0], [50,-50,  0]],
    [[-50,-16, 0], [-16,-16, 120], [ 16,-16, 120], [50,-16, 0]],
    [[-50, 16, 0], [-16, 16, 120], [ 16, 16, 120], [50, 16, 0]],
    [[-50, 50, 0], [-16, 50, 0], [ 16, 50, 0], [50, 50,  0]],
    // u=0,v=1                                         u=1,v=1
];
vnf = bezier_vnf(patch, splinesteps=64);
vnf_polyhedron(vnf);

//debug_bezier_patches([patch]);


/*
debug_bezier(patch[0]);
debug_bezier(patch[3]);

col0 = [patch[0][0],patch[1][0],patch[2][0],patch[3][0]];
col1 = [patch[0][1],patch[1][1],patch[2][1],patch[3][1]];
col1 = [patch[0][2],patch[1][2],patch[2][2],patch[3][2]];
col3 = [patch[0][3],patch[1][3],patch[2][3],patch[3][3]];

debug_bezier(left);
debug_bezier(right);

*/