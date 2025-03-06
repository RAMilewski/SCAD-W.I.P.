include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

spec = [ IDENT,  mb_disk(1,5) ];
bbox = [[-15,-15,-10], [15,15,10]];
left (10) metaballs(spec, bbox, voxel_size = 1, debug = true, show_box = false);
right(10) metaballs(spec, bbox, voxel_size = 1.2, debug = true, show_box = false);