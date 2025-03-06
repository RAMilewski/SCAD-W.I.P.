include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

voxel_size = 1; //[0.25:0.25:2]
cutoff1 = 5;    //[5:1:50]
cutoff2 = 5;    //[5:1:50] 
influence1 = 1; //[0.5:.25:50]
influence2 = 1; //[0.5:.25:50]
spacing = 20;   //[0:1:25]
/* [flags] */
db = false;  //[true,false]
box = false; //[true,false]

spec = [
    IDENT, mb_sphere(r=5, cutoff = cutoff1, influence = influence1),
    right(spacing), mb_sphere(r=5, cutoff = cutoff2, influence = influence2),
];
boundingbox = [[-10,-10,-10], [30,10,10]];
metaballs(spec, boundingbox, voxel_size, debug =  db, show_box = box, show_stats = true);