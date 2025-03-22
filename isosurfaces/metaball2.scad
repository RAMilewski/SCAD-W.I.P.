include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>
centers = [[-1,0,0], [1.25,0,0]];
spec = [
    move(centers[0]) * xscale(0.8), mb_sphere(8),
    move(centers[1]), mb_sphere(3, influence = 1.5, negative=true)
    
];
voxel_size = 0.25;
boundingbox = [[-7,-6,-6], [3,6,6]];
%metaballs(spec, boundingbox, voxel_size);
color("green") move_copies(centers) sphere(d=1, $fn=16);