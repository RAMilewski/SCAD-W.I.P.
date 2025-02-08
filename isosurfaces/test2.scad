 include<BOSL2/std.scad>
 include <BOSL2/isosurface.scad>

 stats = false; // [true,false]

isovalue = 1;
voxel_size = 1;
bounding_box = [[-10,-10,-10],[10,10,10]];
 
funcs = [ up(5), mb_sphere(5) ];

top_half()
metaballs(funcs = funcs, isovalue=isovalue, bounding_box = bounding_box, voxel_size = voxel_size, show_stats = stats);


