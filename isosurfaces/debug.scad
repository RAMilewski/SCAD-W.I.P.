include <BOSL2/std.scad>
include <BOSL2/isosurface.scad>

funcs = [
      left(10), mb_sphere(3),
      right(10), mb_sphere(3),
      fwd(20), mb_sphere(0.5, influence = 4), 
   ];
   voxelsize = 1;
   boundingbox = [[-20,-15, -10], [20, 20, 15]];
   metaballs(funcs, voxelsize, boundingbox, isovalue=1);



