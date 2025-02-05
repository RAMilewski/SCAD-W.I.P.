include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

stats = false; // [true,false]


bounding_box = [[-30,-10,-15],[30,10,15]];
funcs = [
    scale([1.5,4,6]), mb_sphere(3),
    right(1), mb_sphere(3, influence = 3),
];  
isovalue = 1;
voxel_size = .5;

metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);


/* */