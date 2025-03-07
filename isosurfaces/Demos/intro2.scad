
voxel_size = 1; // [0.5:0.5:3]
c = 5;   
sp = 20; // spacing
/* [flags] */
db = false;  //[true,false]
box = false; //[true,false]

include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
spec = [
    move([-1.5 * sp,sp]), mb_sphere(r=5, cutoff = c),
    move([-0.5 * sp,sp]), mb_cuboid(5, squareness = 1, cutoff = c),
    move([0.5 * sp,sp]),  mb_cyl(h = 8, r1 = 5, r2 = 3, cutoff = c),
    move([1.5 * sp,sp]),  mb_capsule(h = 10, r = 3, cutoff = c),
    move([-1.5 * sp,0]),  mb_disk(h = 1, r = 5, cutoff = c),
    move([-0.5 * sp,0]),  mb_connector([-2,2,-3],[2,-2,3], r= 2, cutoff = c), 
    move([0.5 * sp,0]),   mb_torus(r_min = 1, r_maj = 4, cutoff = c),
    move([1.5 * sp,0]),   mb_octahedron(10, squareness = 0.5, cutoff = c),
];
boundingbox = [[-35,-5,-5], [35,25,5]];
metaballs(spec, boundingbox, voxel_size, debug =  db, show_box = box, show_stats = true);

